#!/bin/bash

echo "🚀 Installing ArgoCD Image Updater..."

# Install ArgoCD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

echo "⏳ Waiting for Image Updater to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-image-updater -n argocd

# Create GHCR secret for private registry access (if needed)
echo "🔐 Creating GHCR registry secret..."
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -s -p "Enter your GitHub Personal Access Token (with packages:read scope): " GITHUB_TOKEN
echo ""

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username="$GITHUB_USERNAME" \
  --docker-password="$GITHUB_TOKEN" \
  -n argocd

# Apply the updated ArgoCD application with image updater annotations
echo "📦 Applying ArgoCD Application with Image Updater..."
kubectl apply -f argocd/image-updater-application.yaml

echo "✅ Setup complete!"
echo ""
echo "🔄 How it works now:"
echo "1. Push code to master branch"
echo "2. GitHub Actions builds and pushes image to GHCR"
echo "3. ArgoCD Image Updater detects new image in registry"
echo "4. Image Updater automatically updates Helm values"
echo "5. ArgoCD syncs and deploys the new image"
echo ""
echo "📊 Monitor Image Updater logs:"
echo "kubectl logs -f deployment/argocd-image-updater -n argocd"
