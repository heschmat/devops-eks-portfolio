# 🚀 DevOps EKS Portfolio

![Terraform](https://img.shields.io/badge/IaC-Terraform-blueviolet)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)
![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-blue)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-red)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-green)

## 📖 Overview

This repository demonstrates a **production-grade DevOps pipeline** for deploying a containerized Go application onto **Amazon EKS**, using **Terraform** for Infrastructure as Code, **GitOps (Argo CD)** for deployments, and **Kubernetes add-ons** like Cluster Autoscaler and AWS Load Balancer Controller.

It showcases end-to-end automation:

* **Provisioning** cloud infrastructure (VPC, subnets, EKS, IAM roles)
* **Deploying** workloads with Helm and GitOps
* **Scaling** clusters automatically
* **Exposing** services via AWS ALB
* **Managing** deployments with ArgoCD

This project highlights modern **DevOps + Cloud Native practices**: IaC, GitOps, CI/CD, Observability, and Scalability.

---

## 🏗️ Architecture

```
+------------------------------------------------------------+
|                        VPC (10.0.0.0/16)                   |
|                                                            |
|   🌐 Internet Gateway (IGW)                                |
|                |                                           |
|   +----------------------+    +----------------------+     |
|   | Public Subnet A      |    | Public Subnet B      |     |
|   | (10.0.0.0/19)        |    | (10.0.32.0/19)       |     |
|   | Load Balancers (ALB) |    | Load Balancers (ALB) |     |
|   +----------------------+    +----------------------+     |
|                |                       |                   |
|                +-----------+-----------+                   |
|                            |                               |
|                      🔄 NAT Gateway                        |
|                            |                               |
|   +----------------------+    +----------------------+     |
|   | Private Subnet A     |    | Private Subnet B     |     |
|   | (10.0.64.0/19)       |    | (10.0.96.0/19)       |     |
|   | EKS Worker Nodes     |    | EKS Worker Nodes     |     |
|   +----------------------+    +----------------------+     |
|                                                            |
+------------------------------------------------------------+
```

Components:

* **VPC + Subnets** (Terraform `vpc.tf`)
* **EKS Cluster + Node Groups** (Terraform `eks.tf`)
* **IAM Roles for Service Accounts** (IRSA for Autoscaler & ALB Controller)
* **Cluster Autoscaler** (Helm chart)
* **AWS Load Balancer Controller** (Helm chart)
* **Argo CD** (GitOps controller for app deployments)

---

## ⚙️ Tools & Technologies

* **Terraform** → Infrastructure as Code (VPC, EKS, IAM, etc.)
* **AWS EKS** → Managed Kubernetes control plane
* **Helm** → Kubernetes package management
* **Argo CD** → GitOps-based Continuous Delivery
* **Cluster Autoscaler** → Dynamic scaling of worker nodes
* **AWS Load Balancer Controller** → ALB/NLB for Kubernetes Ingress
* **GitHub Actions** → CI/CD pipeline automation

---

## 🚀 Getting Started

### 1️⃣ Prerequisites

* AWS CLI v2 installed & configured
* Terraform >= 1.13.0
* kubectl >= 1.32
* helm >= 3.0

### 2️⃣ Clone the Repo

```bash
git clone https://github.com/heschmat/devops-eks-portfolio.git
cd devops-eks-portfolio
```

### 3️⃣ Deploy the Infrastructure

```bash
terraform init
terraform apply -var="eks_admin_principal_arn=arn:aws:iam::<account_id>:user/<username>"
```

This provisions:

* VPC with public/private subnets
* EKS cluster with managed node groups
* IAM roles for autoscaler + ALB

### 4️⃣ Update kubeconfig

```bash
aws eks update-kubeconfig --name static-go-app --region us-east-1
```

### 5️⃣ Deploy Add-ons

Terraform will install via Helm:

* Cluster Autoscaler
* AWS Load Balancer Controller
* Argo CD

---

## 📦 CI/CD Pipeline

* **GitHub Actions** pipeline builds & pushes Docker images to ghcr.io
* Argo CD pulls manifests from GitHub and deploys to EKS.
* Autoscaler adjusts worker nodes based on workload.
* ALB exposes services externally.

---

## 📊 Future Enhancements

* 🔐 **DevSecOps**: Add security scanning (Trivy, Snyk).
* 📈 **Observability**: Add Prometheus + Grafana dashboards.
* 🤖 **AI/Ops**: Experiment with AI-driven anomaly detection & auto-remediation.
* 🌍 **Multi-cloud**: Extend Terraform to Azure/GCP for hybrid workloads!!!

---

## 👤 Author

**Heschmat**
DevOps Engineer | Cloud | Kubernetes | Terraform | GitOps

📫 Connect with me: [LinkedIn](https://www.linkedin.comheschmat/) | [GitHub](https://github.com/heschmat)
