#!/bin/bash

echo "🚀 ArgoCD Dual-Approach Setup for CI/CD Demo"
echo "=============================================="
echo ""
echo "This script sets up both GitOps approaches:"
echo "1. 📝 Git-based: Pipeline commits to Helm values"
echo "2. 📦 Registry-based: ArgoCD Image Updater monitors GHCR"
echo ""

# Function to setup git-based approach
setup_git_based() {
    echo "📝 Setting up Git-based GitOps approach..."
    kubectl apply -f argocd/application.yaml
    echo "✅ Git-based ArgoCD application created"
    echo "   - Name: cicd-demo-git-based"
    echo "   - Namespace: default"
    echo "   - Monitors: Git repository for Helm values changes"
}

# Function to setup registry-based approach
setup_registry_based() {
    echo "📦 Setting up Registry-based GitOps approach..."
    
    # Install ArgoCD Image Updater if not already installed
    if ! kubectl get deployment argocd-image-updater -n argocd &>/dev/null; then
        echo "Installing ArgoCD Image Updater..."
        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
        echo "⏳ Waiting for Image Updater to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/argocd-image-updater -n argocd
    else
        echo "ArgoCD Image Updater already installed"
    fi
    
    # Create GHCR secret for registry access
    if ! kubectl get secret ghcr-secret -n argocd &>/dev/null; then
        echo "🔐 Creating GHCR registry secret..."
        read -p "Enter your GitHub username: " GITHUB_USERNAME
        read -s -p "Enter your GitHub Personal Access Token (with packages:read scope): " GITHUB_TOKEN
        echo ""
        
        kubectl create secret docker-registry ghcr-secret \
          --docker-server=ghcr.io \
          --docker-username="$GITHUB_USERNAME" \
          --docker-password="$GITHUB_TOKEN" \
          -n argocd
    else
        echo "GHCR secret already exists"
    fi
    
    # Apply registry-based application
    kubectl apply -f argocd/image-updater-application.yaml
    echo "✅ Registry-based ArgoCD application created"
    echo "   - Name: cicd-demo-registry-based"
    echo "   - Namespace: registry-demo"
    echo "   - Monitors: GHCR for 'registry-latest' tag"
}

# Main menu
echo "Choose setup option:"
echo "1) Git-based approach only"
echo "2) Registry-based approach only"
echo "3) Both approaches (recommended)"
echo "4) Status check"
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        setup_git_based
        ;;
    2)
        setup_registry_based
        ;;
    3)
        setup_git_based
        echo ""
        setup_registry_based
        ;;
    4)
        echo "📊 Current ArgoCD Applications:"
        kubectl get applications -n argocd
        echo ""
        echo "📊 ArgoCD Image Updater status:"
        kubectl get deployment argocd-image-updater -n argocd 2>/dev/null || echo "Not installed"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎯 How to use each approach:"
echo ""
echo "📝 Git-based GitOps:"
echo "   - Use: .github/workflows/cicd.yml (current default)"
echo "   - Trigger: Push to master branch"
echo "   - Flow: Code → Build → Push Image → Update Git → ArgoCD Sync"
echo ""
echo "📦 Registry-based GitOps:"
echo "   - Use: .github/workflows/cicd-registry.yml"
echo "   - Trigger: Manual workflow_dispatch"
echo "   - Flow: Code → Build → Push Image → Image Updater → ArgoCD Sync"
echo ""
echo "📱 Monitor deployments:"
echo "   kubectl get applications -n argocd"
echo "   kubectl logs -f deployment/argocd-image-updater -n argocd  # For registry-based"
echo ""
echo "🌐 Access ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   https://localhost:8080"
echo ""
echo "✅ Setup complete!"
