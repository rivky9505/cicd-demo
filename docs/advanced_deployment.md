# Advanced CI/CD Deployment Strategies

This document outlines advanced deployment strategies that can be implemented as extensions to the basic CI/CD pipelines in this project.

## Blue/Green Deployment

Blue/Green deployment involves maintaining two identical production environments: "Blue" (current) and "Green" (new). This allows for zero-downtime deployments by switching traffic once the new environment is verified.

### Kubernetes Implementation

```yaml
# Blue deployment (current version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo-blue
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
      version: blue
  template:
    metadata:
      labels:
        app: cicd-demo
        version: blue
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:current
---
# Green deployment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo-green
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
      version: green
  template:
    metadata:
      labels:
        app: cicd-demo
        version: green
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
---
# Service (initially pointing to blue)
apiVersion: v1
kind: Service
metadata:
  name: cicd-demo
  namespace: default
spec:
  ports:
  - port: 80
    targetPort: 5000
  selector:
    app: cicd-demo
    version: blue  # Switch to 'green' to complete the deployment
  type: ClusterIP
```

## Canary Deployment

Canary deployments gradually roll out changes to a small subset of users before deploying to the entire infrastructure.

### Kubernetes Implementation

```yaml
# Original deployment (90% of traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo-stable
  namespace: default
spec:
  replicas: 9  # 90% of the pods
  selector:
    matchLabels:
      app: cicd-demo
      track: stable
  template:
    metadata:
      labels:
        app: cicd-demo
        track: stable
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:current
---
# Canary deployment (10% of traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo-canary
  namespace: default
spec:
  replicas: 1  # 10% of the pods
  selector:
    matchLabels:
      app: cicd-demo
      track: canary
  template:
    metadata:
      labels:
        app: cicd-demo
        track: canary
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
---
# Service (selects both stable and canary)
apiVersion: v1
kind: Service
metadata:
  name: cicd-demo
  namespace: default
spec:
  ports:
  - port: 80
    targetPort: 5000
  selector:
    app: cicd-demo  # This will select both stable and canary pods
  type: ClusterIP
```

## Feature Flags

Feature flags allow you to toggle features on or off without deploying new code.

### Implementation Example

1. Add a feature flag library to the application:

```
pip install flask-featureflags
```

2. Modify `app.py` to use feature flags:

```python
from flask import Flask, jsonify
from flask_featureflags import FeatureFlag
import os

app = Flask(__name__)
feature_flags = FeatureFlag(app)

# Configure feature flags
app.config['FEATURE_FLAGS'] = {
    'new_feature': os.environ.get('ENABLE_NEW_FEATURE', 'False').lower() == 'true'
}

@app.route('/')
def hello():
    return jsonify({
        "message": "Hello from CI/CD Demo App!",
        "environment": os.environ.get("ENVIRONMENT", "development"),
        "version": os.environ.get("APP_VERSION", "1.0.0")
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/new-feature')
@feature_flags.is_active('new_feature')
def new_feature():
    return jsonify({"message": "This is a new feature"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
```

3. Modify the Kubernetes deployment to enable the feature flag:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
  template:
    metadata:
      labels:
        app: cicd-demo
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        ports:
        - containerPort: 5000
        env:
        - name: ENVIRONMENT
          value: production
        - name: APP_VERSION
          value: ${IMAGE_TAG}
        - name: ENABLE_NEW_FEATURE
          value: "true"  # Toggle to enable/disable the feature
```

## A/B Testing

A/B testing is similar to canary deployments but focuses on testing different versions of a feature to gather user feedback and metrics.

### Implementation Example

1. Create two deployments with different versions:

```yaml
# Version A
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo-a
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
      version: a
  template:
    metadata:
      labels:
        app: cicd-demo
        version: a
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:versionA
        env:
        - name: UI_VARIANT
          value: "A"

# Version B
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo-b
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
      version: b
  template:
    metadata:
      labels:
        app: cicd-demo
        version: b
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:versionB
        env:
        - name: UI_VARIANT
          value: "B"
```

2. Use a service mesh like Istio for sophisticated traffic splitting:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cicd-demo
spec:
  hosts:
  - cicd-demo
  http:
  - route:
    - destination:
        host: cicd-demo
        subset: version-a
      weight: 50
    - destination:
        host: cicd-demo
        subset: version-b
      weight: 50
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: cicd-demo
spec:
  host: cicd-demo
  subsets:
  - name: version-a
    labels:
      version: a
  - name: version-b
    labels:
      version: b
```

## Progressive Delivery with Argo Rollouts

Argo Rollouts is a Kubernetes controller that provides advanced deployment capabilities:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: cicd-demo-rollout
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 1h}
      - setWeight: 40
      - pause: {duration: 1h}
      - setWeight: 60
      - pause: {duration: 1h}
      - setWeight: 80
      - pause: {duration: 1h}
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: cicd-demo
  template:
    metadata:
      labels:
        app: cicd-demo
    spec:
      containers:
      - name: cicd-demo
        image: ${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        ports:
        - name: http
          containerPort: 5000
          protocol: TCP
```

## Using These Advanced Strategies

To implement these strategies:

1. **Prerequisites**: 
   - Kubernetes cluster with necessary controllers (Istio for A/B testing, Argo Rollouts for progressive delivery)
   - Monitoring setup to track deployment success metrics

2. **Pipeline Integration**:
   - Modify the CI/CD pipeline to include the advanced deployment strategy
   - Add verification steps between deployment phases
   - Implement automatic rollback on failure

3. **Observability**:
   - Ensure proper logging and monitoring is in place
   - Track metrics for each version/variant
   - Set up alerts for deployment issues
