# Deploying AWS Load Balancer Controller on Amazon EKS

This guide walks you through the steps to expose your application publicly on an Amazon EKS cluster using the AWS Load Balancer Controller (ALB Ingress Controller).
I assume you've followed the instructions in the `eks/README.md` already.
---

## ✅ 1. Prerequisites

* Ensure an EKS cluster is up and running.
* `kubectl` is configured to access your cluster.
* IAM OIDC provider is associated with the cluster.

### 🔎 Verify EKS Cluster Status

```bash
aws eks list-clusters --region $this_region
```

```bash
kubectl config current-context
```

```bash
aws eks describe-cluster --name $this_cluster --region $this_region \
  --query "cluster.status"
```

#### ✅ Expected Output

```output
"ACTIVE"
```

### 📡 Verify Node Connectivity

```bash
kubectl get nodes
```

If you encounter an error such as:

```output
Unable to connect to the server
```

Update your kubeconfig:

```bash
aws eks update-kubeconfig --name $this_cluster --region $this_region
```

### 🔐 Verify IAM OIDC Provider

```bash
aws eks describe-cluster \
  --name $this_cluster \
  --region $this_region \
  --query "cluster.identity.oidc.issuer" \
  --output text
```

#### ✅ Expected Output

```output
https://oidc.eks.us-east-1.amazonaws.com/id/1A9EECACB7125AD86735E47A1B0B9332
```

If not enabled:

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster $this_cluster \
  --region $this_region \
  --approve
```

---

## 🛠️ 2. Install AWS Load Balancer Controller

### 📦 Step 1: Create IAM Policy

Download the IAM policy:

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

Create the IAM policy:

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

#### ✅ Sample Output
```output
{
    "Policy": {
        "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
        "PolicyId": "ANPA3UPVLQK2JPYM4CEJA",
        "Arn": "arn:aws:iam::799915344564:policy/AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-06-03T16:33:16+00:00",
        "UpdateDate": "2025-06-03T16:33:16+00:00"
    }
}

```

💡 *Note: If the policy already exists, reuse the ARN.*

### 👤 Step 2: Create IAM Role and Service Account

Get your AWS account ID:

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

Create the service account:

```bash
eksctl create iamserviceaccount \
  --cluster $this_cluster \
  --region $this_region \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

### 🎛️ Step 3: Install Controller via Helm

Add and update the Helm repo:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

Get the VPC ID:

```bash
VPC_ID=$(aws eks describe-cluster \
  --name $this_cluster \
  --region $this_region \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)
```

Install the controller:

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$this_cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$this_region \
  --set vpcId=$VPC_ID \
  --set ingressClass=alb
```

✅ *AWS Load Balancer Controller installed!*

Notice that we passed `--set ingressClass=alb` tot match `spec.ingressClassName` in ingress definition.

---

## 🔍 Step 4: Verify Installation

Check deployment status:

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Expected to see READY pods and AVAILABLE replicas.

Get the ingress address (note: beforehand you've had to deploy application resoures to the cluster.)
Refer to the corresponding instructions in sections about Helm or kubernetes manifests.
```bash

# Get the public DNS of the LB:
kubectl get ing -n $this_namespace
```

#### ✅ Example Output

```output
NAME                    CLASS   HOSTS   ADDRESS                                                                  PORTS   AGE
go-static-app-ingress   alb     *       k8s-goappsta-gostatic-b4757a4b42-109126709.us-east-1.elb.amazonaws.com   80      19m
```

Wait couple of minutes for the Application LB to become `Active`. The app should be reachable via the ADDRESS above, which is ALB's DNS name.

Check ALB is accessible:
```bash
curl k8s-goappsta-gostatic-b4757a4b42-109126709.us-east-1.elb.amazonaws.com
```
Or simply open it in the browser.

@TODO: host-based routing in ingress.

Bellow are several commands to investigate if the app is not reachable at the LB's DNS.
```sh
# Helpful commands for debugging:
helm list --all-namespaces

# or:
helm list -A

helm upgrade --install go-static-app ./go-static-app -n $this_namespace

```

If the ADDRESS is missing, troubleshoot:

```bash
kubectl describe ingress go-static-app-ingress -n $this_namespace
```

Look for:

```output
Normal SuccessfullyReconciled
```

Or check logs:

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

---

## ⚙️ 3. Configure Ingress Class

Ensure your Ingress manifests contain:

```yaml
spec:
  ingressClassName: alb
```

---

✅ *You’ve successfully deployed the AWS Load Balancer Controller and exposed your application through an ALB!*
