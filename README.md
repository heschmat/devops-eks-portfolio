# DevOps Portfolio Project: Go Static App Deployment

![CI/CD](https://img.shields.io/github/actions/workflow/status/heschmat/devops_eks_portfolio/cicd.yml?branch=main)
![License](https://img.shields.io/github/license/heschmat/devops_eks_portfolio)

## Overview

This project demonstrates a complete DevOps workflow by deploying a simple static Go application with three pages using Docker, Kubernetes, GitHub Actions, and Argo CD on Amazon EKS. It reflects production-grade practices including secure containerization, CI/CD automation, and GitOps deployment.

---

## 🔧 Tech Stack

* **Language:** Go (static site)
* **Containerization:** Docker, Multi-stage builds, Distroless base image
* **CI/CD:** GitHub Actions, Grivy for image scanning
* **Orchestration:** Kubernetes (KinD for local, EKS for production)
* **Package Management:** Helm
* **GitOps:** Argo CD
* **Cloud Provider:** AWS (EKS, IAM, OIDC)

---

## 🚀 DevOps Workflow

### 1. Local Development

* `Dockerfile.dev` and `docker-compose.yaml` for development setup
* Run, build, test the app locally with port forwarding

### 2. Production Image

* Multi-stage Dockerfile ending with **distroless image** for security & minimal size
* Built and pushed to `ghcr.io`

### 3. Kubernetes Manifests

* Raw manifests created with attention to:

  * Namespace isolation
  * Correct `containerPort`, `targetPort`, selectors
  * `imagePullSecrets` for private registry access

### 4. KinD Testing

* Validate manifest correctness in a KinD cluster
* Debug deployment issues locally before cloud rollout

### 5. Helm Chart

* Created a Helm chart for easy installation and upgrades

### 6. EKS Deployment

* Created an EKS cluster using `eksctl`
* Deployed the app via Helm to a dedicated namespace

### 7. Ingress & Load Balancing

* Configured ALB Ingress Controller with:

  * OIDC provider
  * IAM role for controller
  * Helm-based ALB installation
* Verified external access via ALB

### 8. GitHub Actions CI/CD

Jobs include:

* ✅ Unit Testing
* ✅ Static Code Analysis
* ✅ Docker Build, Scan (Grivy), and Push to GHCR
* ✅ `values.yaml` image tag update and push to GH for Argo CD sync

### 9. GitOps with Argo CD

* Deployed Argo CD to EKS
* Continuous deployment triggered by changes in Helm values

---

## 📈 Next Steps

* **Infrastructure as Code (IaC):** Replacing `eksctl` setup with **Terraform** for EKS and AWS resources
* **Observability:** Integrate **Prometheus + Grafana** for monitoring, custom metrics, and dashboards

---

## 📂 Repository Structure

```
.
├── Helm/                   # Helm chart
├── .github/workflows/      # GitHub Actions CI/CD
├── Dockerfile              # Production image (distroless)
├── Dockerfile.dev          # Dev image
├── docker-compose.yaml     # Local development setup
├── k8s/manifests/          # K8s namespace, service, deployment, ingress
└── README.md
```

---

## 📸 Screenshots

> @TODO: Add screenshots of the app UI, Argo CD dashboard, GitHub Actions runs, or Prometheus graphs.

---

## 🌐 Access

Once deployed on EKS:

```bash
kubectl get svc -n <namespace>
kubectl get nodes -o wide
```

App should be reachable at `http://<node_public_ip>:<node_port>` or via **ALB DNS** after Ingress is configured.

---

## 🧠 Learning Outcomes

* End-to-end DevOps lifecycle
* CI/CD and GitOps integration
* Secure container builds
* AWS IAM, OIDC, EKS, ALB experience
* Helm templating and best practices

---

## 📃 License

[MIT](./LICENSE)
