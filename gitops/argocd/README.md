# Argo CD Installation and Application Setup Guide

## Installation

1. **Create the Argo CD namespace:**

```sh
kubectl create namespace argocd
```

2. **Install Argo CD components:**

```sh
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

3. **Wait for all Argo CD pods to become ready:**

```sh
kubectl get pods -n argocd -w
```

4. **Check the services in the `argocd` namespace:**

```sh
kubectl get svc -n argocd
```

## Accessing the Argo CD UI

### Option 1: Port-forwarding (for testing/local access)

To expose the Argo CD UI locally via port-forwarding:

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0
```

Access the UI in your browser at:

```
https://<EC2_INSTANCE_PUBLIC_IP>:8080/
```

Retrieve the initial admin password:

```sh
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

* **Username:** `admin`
* **Password:** (output from the above command)

### Option 2: LoadBalancer (recommended for remote access)

To expose Argo CD using a LoadBalancer service:

```sh
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

Wait a few minutes for the LoadBalancer to provision, then retrieve the external IP:

```sh
kubectl get svc argocd-server -n argocd
```

Access the UI at:

```
https://<EXTERNAL-IP>
```

## Creating an Argo CD Application

You can create and manage Argo CD applications using either the UI or declarative YAML files.

### ✅ Option 1: Using the Argo CD UI (Manual Setup)

1. Access the Argo CD UI as described above.
2. Click on **"+ NEW APP"**.
3. Fill in the details:

   * Application Name
   * Git Repository URL
   * Path to Kubernetes manifests or Helm chart
   * Target cluster and namespace
4. Click **Create** to finish.

> 📸 *Screenshots and walkthrough coming soon...*

### ✅ Option 2: Declarative YAML (Infrastructure as Code)

Create an Argo CD `Application` manifest (e.g. `k8s/manifests/argo-app.yaml`) and apply it:

```sh
kubectl apply -f k8s/manifests/argo-app.yaml
```

This approach is recommended for GitOps workflows and version control.
