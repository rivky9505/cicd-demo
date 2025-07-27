# GitOps Deployment Approaches

This project supports two different GitOps deployment approaches with ArgoCD:

## 🌟 Quick Start

Run the setup script to configure either or both approaches:

```bash
chmod +x setup-dual-approach.sh
./setup-dual-approach.sh
```

## 📝 Approach 1: Git-based GitOps (Default)

**When to use:** Traditional GitOps, audit trail in Git, team collaboration

### How it works:
1. Push code to `master` branch
2. GitHub Actions builds and pushes Docker image to GHCR
3. Pipeline updates `helm/cicd-demo/values.yaml` with new image tag
4. Pipeline commits changes back to Git
5. ArgoCD detects Git changes and deploys

### Files:
- **Workflow:** `.github/workflows/cicd.yml`
- **ArgoCD App:** `argocd/application.yaml`
- **Deployment:** `default` namespace

### Trigger:
```bash
# Automatic on push to master
git push origin master
```

---

## 📦 Approach 2: Registry-based GitOps

**When to use:** Cleaner Git history, registry as source of truth, advanced scenarios

### How it works:
1. Run registry-based workflow
2. GitHub Actions builds and pushes Docker image with `registry-latest` tag
3. ArgoCD Image Updater monitors GHCR for new images
4. Image Updater automatically updates Helm values
5. ArgoCD detects changes and deploys

### Files:
- **Workflow:** `.github/workflows/cicd-registry.yml`
- **ArgoCD App:** `argocd/image-updater-application.yaml`
- **Deployment:** `registry-demo` namespace

### Trigger:
```bash
# Manual workflow dispatch
gh workflow run cicd-registry.yml
# OR via GitHub UI: Actions → CI/CD with Registry-based GitOps → Run workflow
```

---

## 📊 Monitoring

### Check ArgoCD Applications:
```bash
kubectl get applications -n argocd
```

### Monitor Registry-based approach:
```bash
kubectl logs -f deployment/argocd-image-updater -n argocd
```

### Check deployments:
```bash
# Git-based approach
kubectl get pods -n default

# Registry-based approach  
kubectl get pods -n registry-demo
```

---

## 🔄 Comparison

| Feature | Git-based | Registry-based |
|---------|-----------|----------------|
| **Git History** | More commits | Cleaner |
| **Setup Complexity** | Simple | Advanced |
| **Registry as Source** | ❌ | ✅ |
| **Automatic on Push** | ✅ | ❌ |
| **Audit Trail** | Git commits | ArgoCD events |
| **Rollback** | Git revert | Manual |

---

## 🛠 Troubleshooting

### Git-based issues:
- Check GitHub Actions logs
- Verify Git permissions
- Check ArgoCD sync status

### Registry-based issues:
- Check Image Updater logs: `kubectl logs deployment/argocd-image-updater -n argocd`
- Verify GHCR credentials
- Check registry permissions

### Both approaches:
- ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- Get admin password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`
