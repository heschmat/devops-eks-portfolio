#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Cleaning up Kubernetes resources that create AWS ENIs / ALBs..."

# Delete all ingress resources
echo "➡️ Deleting all Ingresses..."
kubectl delete ingress --all --all-namespaces --ignore-not-found=true

# Delete all LoadBalancer services
echo "➡️ Deleting all LoadBalancer Services..."
kubectl get svc -A -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' \
  | while read namespace name; do
      if [[ -n "$namespace" && -n "$name" ]]; then
        kubectl delete svc "$name" -n "$namespace" --ignore-not-found=true
      fi
    done

# Uninstall AWS Load Balancer Controller (if installed via Helm)
if helm status aws-load-balancer-controller -n kube-system &>/dev/null; then
  echo "➡️ Uninstalling AWS Load Balancer Controller..."
  helm uninstall aws-load-balancer-controller -n kube-system
fi

# Uninstall cert-manager (optional)
if helm status cert-manager -n cert-manager &>/dev/null; then
  echo "➡️ Uninstalling cert-manager..."
  helm uninstall cert-manager -n cert-manager
  kubectl delete ns cert-manager --ignore-not-found=true
fi

echo "✅ Kubernetes cleanup complete!"
echo "👉 Now check EC2 → Load Balancers & Network Interfaces. Then run: terraform destroy"
