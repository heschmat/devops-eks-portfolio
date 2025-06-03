# EKS Deployment Guide for `go-static-app`

This guide walks you through the steps to deploy the `go-static-app` on Amazon EKS using Helm.

## Environment Setup

Set the following environment variables to avoid typos:

```bash
export this_cluster="go-app-static"
export this_region="us-east-1"
export nodegroup_name="go-app-static-ng"
export this_namespace="go-app-static"
```

## 1. Create the EKS Cluster

```bash
eksctl create cluster \
  --name $this_cluster \
  --region $this_region \
  --nodegroup-name $nodegroup_name \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --node-type t3.medium
```

## 2. Verify Cluster Context

```bash
kubectl config current-context
```

If needed, update the kubeconfig:

```bash
aws eks update-kubeconfig --name $this_cluster --region $this_region
```

## 3. Deploy the Application with Helm

Navigate to your Helm chart directory:

```bash
cd helm
```

Install the chart:

```bash
helm install go-static-app ./go-static-app \
  --create-namespace \
  --namespace $this_namespace
```

To apply updates:

```bash
helm upgrade --install go-static-app ./go-static-app \
  -n $this_namespace
```

## 4. Create Image Pull Secret

The image is hosted on GitHub Container Registry (GHCR). Create a secret for authentication:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<GH_USERNAME> \
  --docker-password=<GH_PAT> \
  --namespace $this_namespace
```

Ensure the secret type is correct:

```bash
kubectl get secret ghcr-secret -n $this_namespace -o yaml
```

## 5. (Optional) Pull Image Locally for Debugging

```bash
docker login ghcr.io -u <GH_USERNAME> -p <GH_PAT>
docker pull ghcr.io/<GH_USERNAME>/<GH_REPO>:<IMAGE_TAG>
```

## 6. Verify Deployment

```bash
kubectl get all -n $this_namespace
```

## 7. Test the App with NodePort (Temporary)

Expose the service using `NodePort` for testing:

```bash
helm upgrade --install go-static-app ./go-static-app \
  -n $this_namespace \
  --set service.type=NodePort \
  --set service.nodePort=30080
```

Check the node external IP:

```bash
kubectl get nodes -o wide
```

Verify service details:

```bash
kubectl get svc -n $this_namespace
```

Ping the app:

```bash
curl http://<node-external-ip>:30080
```

> ⚠️ If unreachable, the likely cause is EC2 security group restrictions.

### Allow NodePort Traffic in EC2 Security Group

1. Go to the **EC2 Console > Security Groups**.
2. Locate the group associated with your EKS nodes.
3. Edit inbound rules:

   * **Type**: Custom TCP
   * **Port Range**: 30000-32767 (or just 30080 for minimal access)
   * **Source**: Your IP or `0.0.0.0/0` (not recommended for production)

*@TODO: Add screenshot*

## 8. Revert to ClusterIP After Testing

```bash
helm upgrade --install go-static-app ./go-static-app \
  -n $this_namespace \
  --set service.type=ClusterIP
```

## 9. Port Forwarding & SSH Tunnel Access (*Optional & Secure*)

Use this method for temporary access from your local machine:

### A. Port Forward from EC2:

```bash
kubectl port-forward svc/go-static-app-svc 8080:80 -n $this_namespace
```

Access it on the EC2 instance via:

```bash
curl http://localhost:8080
```

### B. SSH Tunnel to Access from Local Machine:

From your local machine:

```bash
ssh -L 8080:localhost:8080 ec2-user@<EC2_PUBLIC_IP>
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

*@TODO: Add screenshot and instructions for setting up the SSH key and access*

## 10. Cleanup

Delete the cluster to avoid incurring costs:

```bash
eksctl delete cluster --name $this_cluster --region $this_region
```
