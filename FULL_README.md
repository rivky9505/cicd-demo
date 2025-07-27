# 🚀 CI/CD GitOps Demo Project

A comprehensive hands-on project that demonstrates **three different GitOps approaches** for modern Kubernetes deployments. This project is designed as a complete educational resource to teach GitOps principles from zero to production-ready implementations.

## 📚 What You'll Learn

This project provides a **complete GitOps learning experience** covering:

- 🎯 **GitOps Fundamentals** - Core principles and best practices
- 🔄 **Three GitOps Approaches** - Git-based, Registry-based, and Webhook-based
- 🐳 **Container Orchestration** - Docker, Kubernetes, and ArgoCD
- 🛠️ **CI/CD Pipelines** - GitHub Actions automation
- 📦 **Package Management** - Helm charts and versioning
- 🔐 **Security & Permissions** - RBAC, secrets, and access control
- 📊 **Monitoring & Observability** - Deployment tracking and debugging

## 🏗️ Project Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │      GHCR       │    │   Kubernetes    │
│                 │    │  (Container     │    │   (Minikube)    │
│ • App Code      │────│   Registry)     │────│                 │
│ • Dockerfile    │    │                 │    │ • ArgoCD        │
│ • Helm Charts   │    │ • Docker Images │    │ • Applications  │
│ • CI/CD Workflows│   │ • Multi-arch    │    │ • Namespaces    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                        │                        │
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ GitHub Actions  │    │ Image Updater   │    │   ArgoCD UI     │
│                 │    │                 │    │                 │
│ • Test Pipeline │    │ • Registry      │    │ • App Status    │
│ • Build Images  │    │   Monitoring    │    │ • Sync History  │
│ • Deploy Logic  │    │ • Auto Updates  │    │ • Health Checks │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 GitOps Approaches Implemented

This project demonstrates **three distinct GitOps patterns**, each teaching different aspects of modern deployment strategies:

### 🔄 **Approach 1: Git-based GitOps (Traditional)**

**🎓 Learning Objective:** Understand classical GitOps where Git is the single source of truth.

**📁 Files:**
- Workflow: [`.github/workflows/cicd.yml`](.github/workflows/cicd.yml)
- ArgoCD App: [`argocd/application.yaml`](argocd/application.yaml)

**🔄 How it Works:**
```
Code Push → GitHub Actions → Build Image → Update Git → ArgoCD Sync → Deploy
     │              │              │           │            │          │
     └─────────────────────────────────────────────────────────────────┘
                           Git remains source of truth
```

**📝 Implementation Details:**
```yaml
# Trigger: Push to master branch
on:
  push:
    branches: [ master ]
    paths-ignore:
      - 'helm/cicd-demo/values.yaml'  # Prevents infinite loops

# Process:
jobs:
  test:           # Run pytest tests
  build-publish:  # Build multi-arch Docker images
  deploy:         # Update Helm values.yaml → Commit to Git
```

**🎯 Key Learning Points:**
- ✅ **Git as Source of Truth** - All changes tracked in version control
- ✅ **Audit Trail** - Complete deployment history in Git commits
- ✅ **Rollback Capability** - Easy revert via Git operations
- ✅ **Team Collaboration** - Changes reviewable via Pull Requests
- ❌ **Git Noise** - Automated commits clutter repository history
- ❌ **Circular Dependencies** - CI/CD must write back to Git

### 📦 **Approach 2: Registry-based GitOps (Modern)**

**🎓 Learning Objective:** Learn container registry-driven deployments with ArgoCD Image Updater.

**📁 Files:**
- Workflow: [`.github/workflows/cicd-registry.yml`](.github/workflows/cicd-registry.yml)
- ArgoCD App: [`argocd/image-updater-application.yaml`](argocd/image-updater-application.yaml)
- Image Updater: [`argocd/image-updater-config.yaml`](argocd/image-updater-config.yaml)

**🔄 How it Works:**
```
Code Push → GitHub Actions → Build Image → Push to Registry
                                               │
Registry Monitor ← ArgoCD Image Updater ←──────┘
      │                    │
      └── Update Git ←──────┘
            │
    ArgoCD Sync → Deploy
```

**📝 Implementation Details:**
```yaml
# ArgoCD Image Updater Annotations
annotations:
  argocd-image-updater.argoproj.io/image-list: app=ghcr.io/rivky9505/cicd-demo
  argocd-image-updater.argoproj.io/app.update-strategy: newest-build
  argocd-image-updater.argoproj.io/app.allow-tags: regexp:^master-.*
  argocd-image-updater.argoproj.io/write-back-method: git
```

**🎯 Key Learning Points:**
- ✅ **Registry as Source** - Container registry drives deployments
- ✅ **Cleaner Git History** - No automated commits from CI/CD
- ✅ **Decoupled Architecture** - CI and CD are truly separated
- ✅ **Real-time Updates** - Deployments triggered by actual image availability
- ❌ **Complex Setup** - Requires ArgoCD Image Updater configuration
- ❌ **Additional Components** - More moving parts to maintain

### 🔗 **Approach 3: Webhook-based GitOps (Advanced)**

**🎓 Learning Objective:** Implement event-driven deployments using webhooks and external triggers.

**📁 Files:**
- Webhook Receiver: [`argocd/webhook-receiver.yaml`](argocd/webhook-receiver.yaml)
- Setup Script: [`setup-webhook-receiver.sh`](setup-webhook-receiver.sh)

**🔄 How it Works:**
```
External Event → Webhook → Custom Receiver → ArgoCD API → Direct Sync
      │            │            │              │            │
   (Registry)   (HTTP POST)  (Pod in K8s)  (gRPC/REST)   (Deploy)
```

**📝 Implementation Details:**
```yaml
# Webhook Receiver Pod
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webhook-receiver
spec:
  template:
    spec:
      containers:
      - name: webhook
        image: alpine:latest
        command: ["/bin/sh"]
        args: ["/scripts/webhook.sh"]
```

**🎯 Key Learning Points:**
- ✅ **Event-Driven** - React to external system events
- ✅ **Real-time Response** - Immediate deployment triggers
- ✅ **Custom Logic** - Flexible event processing
- ✅ **Integration Friendly** - Works with any webhook source
- ❌ **Complexity** - Requires custom webhook handling
- ❌ **Security Considerations** - Need to secure webhook endpoints

## 📦 Application Components

### 🐍 **Python Flask Application**
```python
# app.py - Simple web service
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from CI/CD GitOps Demo!"

@app.route('/health')
def health():
    return {"status": "healthy"}
```

### 🐳 **Multi-Architecture Docker Setup**
```dockerfile
# Dockerfile - Optimized for production
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

### ⚓ **Helm Chart Structure**
```
helm/cicd-demo/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration
└── templates/
    ├── deployment.yaml # Kubernetes Deployment
    ├── service.yaml    # Kubernetes Service
    └── ingress.yaml    # Ingress configuration
```

## 🚀 Getting Started

### **Prerequisites**
```bash
# Required tools
- Docker Desktop
- Minikube or Kind
- kubectl
- Helm 3.x
- GitHub CLI (optional)
```

### **1. Clone and Setup**
```bash
# Clone the repository
git clone https://github.com/rivky9505/cicd-demo.git
cd cicd-demo

# Make scripts executable
chmod +x setup-*.sh
```

### **2. Start Minikube with ArgoCD**
```bash
# Start Minikube
minikube start --driver=docker

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### **3. Configure GitHub Repository**
```bash
# Create GitHub repository secrets
# Go to: https://github.com/YOUR_USERNAME/cicd-demo/settings/secrets/actions

# Required secrets:
- PUSH_TOKEN: Personal Access Token with repo permissions
```

### **4. Choose Your GitOps Adventure**

#### 🎯 **Option A: Git-based GitOps (Beginner)**
```bash
# Setup Git-based approach
./setup-argocd.sh

# Test with a code change
echo "# Test change" >> README.md
git add README.md
git commit -m "Test Git-based GitOps"
git push origin master
```

#### 📦 **Option B: Registry-based GitOps (Intermediate)**
```bash
# Setup Registry-based approach
./setup-image-updater-fix.sh
kubectl apply -f argocd/image-updater-application.yaml

# Test with manual workflow trigger
gh workflow run cicd-registry.yml
```

#### 🔗 **Option C: Webhook-based GitOps (Advanced)**
```bash
# Setup Webhook receiver
kubectl apply -f argocd/webhook-receiver.yaml

# Test webhook (example with curl)
kubectl port-forward service/webhook-receiver 8080:80 -n argocd &
curl -X POST http://localhost:8080/webhook
```

#### 🚀 **Option D: All Approaches (Expert)**
```bash
# Setup all three approaches
./setup-dual-approach.sh
# Choose option 3 when prompted
```

## 📊 Monitoring and Observability

### **ArgoCD UI Access**
```bash
# Port forward to ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d

# Access UI: https://localhost:8080
```

### **Application Monitoring**
```bash
# Check application status
kubectl get applications -n argocd

# View application details
kubectl describe application cicd-demo-git-based -n argocd

# Check deployed pods
kubectl get pods -n default                    # Git-based
kubectl get pods -n registry-demo              # Registry-based
```

### **Image Updater Monitoring**
```bash
# Check Image Updater logs
kubectl logs -f deployment/argocd-image-updater -n argocd

# Check Image Updater configuration
kubectl get configmap argocd-image-updater-config -n argocd -o yaml
```

### **CI/CD Pipeline Monitoring**
```bash
# Watch GitHub Actions
gh workflow list
gh run list --workflow=cicd.yml

# Check container registry
gh api repos/rivky9505/cicd-demo/packages
```

## 🛠️ Troubleshooting Guide

### **Common Issues and Solutions**

#### 🚨 **GitHub Actions Permission Denied**
```bash
# Problem: remote: Permission to rivky9505/cicd-demo.git denied
# Solution: Create Personal Access Token

# 1. Go to: https://github.com/settings/tokens
# 2. Generate token with 'repo' scope
# 3. Add as repository secret: PUSH_TOKEN
```

#### 🚨 **ArgoCD Application Out of Sync**
```bash
# Manual sync
kubectl patch application cicd-demo-git-based -n argocd \
  --type merge --patch '{"operation":{"sync":{}}}'

# Or via CLI
argocd app sync cicd-demo-git-based
```

#### 🚨 **Image Updater Not Working**
```bash
# Check Image Updater status
kubectl get deployment argocd-image-updater -n argocd

# View detailed logs
kubectl logs deployment/argocd-image-updater -n argocd --previous

# Restart Image Updater
kubectl rollout restart deployment/argocd-image-updater -n argocd
```

#### 🚨 **Minikube Issues**
```bash
# Reset Minikube
minikube delete
minikube start --driver=docker

# Check Minikube status
minikube status
kubectl cluster-info
```

## 📚 Educational Exercises

### **🎓 Exercise 1: Git-based GitOps Flow**
```bash
# Objective: Understand traditional GitOps workflow

# 1. Make a code change
echo 'print("GitOps is awesome!")' >> app.py

# 2. Commit and push
git add app.py
git commit -m "Add GitOps message"
git push origin master

# 3. Observe the pipeline
# - GitHub Actions builds and tests
# - Docker image pushed to GHCR
# - Helm values.yaml updated automatically
# - ArgoCD detects change and deploys

# 4. Verify deployment
kubectl get pods -n default
kubectl logs deployment/cicd-demo -n default
```

### **🎓 Exercise 2: Registry-based GitOps Flow**
```bash
# Objective: Learn registry-driven deployments

# 1. Trigger registry-based workflow
gh workflow run cicd-registry.yml

# 2. Monitor Image Updater
kubectl logs -f deployment/argocd-image-updater -n argocd

# 3. Observe automatic updates
# - New image appears in GHCR
# - Image Updater detects new tag
# - Helm values updated automatically
# - ArgoCD syncs to registry-demo namespace

# 4. Compare namespaces
kubectl get pods -n default        # Git-based deployment
kubectl get pods -n registry-demo  # Registry-based deployment
```

### **🎓 Exercise 3: Multi-Environment Setup**
```bash
# Objective: Simulate production GitOps practices

# 1. Create environment-specific values
cp helm/cicd-demo/values.yaml helm/cicd-demo/values-staging.yaml
cp helm/cicd-demo/values.yaml helm/cicd-demo/values-production.yaml

# 2. Modify staging values
sed -i 's/replicas: 1/replicas: 2/' helm/cicd-demo/values-staging.yaml

# 3. Create staging application
# Edit argocd/application.yaml to point to values-staging.yaml

# 4. Deploy to multiple environments
kubectl apply -f argocd/application-staging.yaml
kubectl apply -f argocd/application-production.yaml
```

### **🎓 Exercise 4: Rollback and Recovery**
```bash
# Objective: Practice GitOps rollback procedures

# 1. Introduce a breaking change
echo 'INTENTIONAL_ERROR' >> app.py
git add app.py
git commit -m "Introduce breaking change"
git push origin master

# 2. Observe failed deployment in ArgoCD UI

# 3. Rollback via Git
git revert HEAD
git push origin master

# 4. Observe automatic recovery
kubectl get pods -n default
```

## 🔧 Advanced Configuration

### **Custom Helm Values**
```yaml
# helm/cicd-demo/values.yaml
image:
  repository: ghcr.io/rivky9505/cicd-demo
  tag: "latest"
  pullPolicy: IfNotPresent

replicaCount: 1

service:
  type: ClusterIP
  port: 80
  targetPort: 5000

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: cicd-demo.local
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### **ArgoCD Application Sets**
```yaml
# argocd/applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cicd-demo-envs
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - env: staging
        namespace: staging
      - env: production
        namespace: production
  template:
    metadata:
      name: 'cicd-demo-{{env}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/rivky9505/cicd-demo.git
        targetRevision: master
        path: helm/cicd-demo
        helm:
          valueFiles:
          - values-{{env}}.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{namespace}}'
```

## 📈 Production Considerations

### **Security Best Practices**
```yaml
# Secure ArgoCD configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  namespace: argocd
data:
  server.insecure: "false"
  server.enable.grpc.web: "true"
  server.disable.auth: "false"
```

### **Resource Management**
```yaml
# Resource quotas and limits
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cicd-demo-quota
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "4"
```

### **Monitoring Integration**
```yaml
# Prometheus monitoring
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: cicd-demo
spec:
  selector:
    matchLabels:
      app: cicd-demo
  endpoints:
  - port: web
    path: /metrics
```

## 🎯 Learning Outcomes

After completing this project, students will understand:

### **📚 Fundamental Concepts**
- ✅ **GitOps Principles** - Declarative, versioned, and automated
- ✅ **Infrastructure as Code** - Everything defined in version control
- ✅ **Continuous Deployment** - Automated application delivery
- ✅ **Container Orchestration** - Kubernetes deployment patterns

### **🛠️ Technical Skills**
- ✅ **CI/CD Pipeline Design** - Multi-stage automation workflows
- ✅ **Container Management** - Docker, registries, and multi-arch builds
- ✅ **Kubernetes Operations** - Deployments, services, and namespaces
- ✅ **ArgoCD Management** - Applications, sync policies, and monitoring

### **🏗️ Architecture Patterns**
- ✅ **Git-based GitOps** - Traditional approach with Git as source of truth
- ✅ **Registry-based GitOps** - Modern pattern using container registries
- ✅ **Event-driven GitOps** - Advanced webhook-based deployments
- ✅ **Multi-environment Management** - Staging, production, and dev environments

### **🔧 Operational Excellence**
- ✅ **Monitoring and Observability** - Application and infrastructure visibility
- ✅ **Security and RBAC** - Access control and secret management
- ✅ **Troubleshooting** - Debugging failed deployments and sync issues
- ✅ **Rollback Strategies** - Recovery from failed deployments

## 🤝 Contributing

This educational project welcomes contributions! Here's how to get involved:

### **Adding New GitOps Patterns**
1. Fork the repository
2. Create a new workflow file in [`.github/workflows/`](.github/workflows/)
3. Add corresponding ArgoCD application in [`argocd/`](argocd/)
4. Update this README with educational content
5. Submit a Pull Request

### **Improving Documentation**
- Add more troubleshooting scenarios
- Create additional exercises
- Enhance architectural diagrams
- Provide multi-language examples

### **Testing and Validation**
- Test on different Kubernetes distributions
- Validate on various operating systems
- Add automated testing scenarios
- Improve error handling

## 📖 Additional Resources

### **Official Documentation**
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### **GitOps Best Practices**
- [GitOps Principles](https://opengitops.dev/)
- [CNCF GitOps Working Group](https://github.com/cncf/tag-app-delivery)
- [GitOps Toolkit](https://toolkit.fluxcd.io/)

### **Advanced Topics**
- [ArgoCD ApplicationSets](https://argocd-applicationset.readthedocs.io/)
- [Progressive Delivery](https://argoproj.github.io/argo-rollouts/)
- [Multi-cluster GitOps](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters)

## 📜 License

This educational project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **ArgoCD Community** - For creating an amazing GitOps platform
- **GitHub Actions Team** - For powerful CI/CD automation
- **Kubernetes Community** - For the container orchestration foundation
- **GitOps Working Group** - For establishing GitOps principles

---

**🎓 Happy Learning!** This project represents a complete journey through modern GitOps practices. Start with the basics and progressively explore advanced patterns as you build confidence with each approach.

**🚀 Ready to begin?** Choose your GitOps adventure and start