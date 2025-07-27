#!/bin/bash

# ArgoCD Setup Script for CI/CD Demo
echo "🚀 Setting up ArgoCD for CI/CD Demo deployment..."

# Check if ArgoCD is running
echo "📋 Checking ArgoCD status..."
kubectl get pods -n argocd

# Apply the ArgoCD Application
echo "📦 Creating ArgoCD Application..."
kubectl apply -f argocd/application.yaml

# Wait for application to be created
echo "⏳ Waiting for ArgoCD Application to be created..."
sleep 5

# Check application status
echo "📊 Checking ArgoCD Application status..."
kubectl get applications -n argocd

# Get ArgoCD UI access information
echo ""
echo "🌐 ArgoCD UI Access:"
echo "Port forward to access ArgoCD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Get admin password:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "✅ Setup complete! Your application should be visible in ArgoCD UI at:"
echo "   https://localhost:8080 (after port forwarding)"
echo ""
echo "📱 The application will automatically sync when you push changes to the master branch."
