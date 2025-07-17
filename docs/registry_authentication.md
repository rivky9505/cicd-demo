# Registry Authentication Guide

This document provides detailed guidance on container registry authentication options for each CI/CD platform in our demonstration project.

## Container Registry Options

### Public Registries

| Registry | Features | Best for | Authentication Method |
|----------|----------|----------|----------------------|
| Docker Hub | - Free for public images<br>- Limited free private images<br>- Wide adoption | Public projects | Username/password or access token |
| GitHub Container Registry (ghcr.io) | - Free for public images<br>- Integrated with GitHub | GitHub-based projects | GitHub token (GITHUB_TOKEN) |
| GitLab Container Registry | - Free for public images<br>- Integrated with GitLab | GitLab-based projects | GitLab CI variables |
| Quay.io | - Free for public images<br>- Advanced security features | Projects requiring image scanning | Robot accounts |

### Private Registries

| Registry | Features | Best for | Authentication Method |
|----------|----------|----------|----------------------|
| Self-hosted Docker Registry | - Full control<br>- No external dependencies | Organizations with security requirements | Username/password or TLS certificates |
| AWS ECR | - Integrated with AWS<br>- IAM authentication | AWS-based infrastructure | IAM roles or access keys |
| Azure Container Registry | - Integrated with Azure<br>- Azure AD authentication | Azure-based infrastructure | Service principals or managed identity |
| Google Container Registry | - Integrated with GCP<br>- IAM authentication | GCP-based infrastructure | Service accounts or access keys |

## Authentication Methods by CI/CD Platform

### GitHub Actions

GitHub Actions provides seamless integration with GitHub Container Registry (ghcr.io).

**Recommended setup for GitHub Actions:**

1. **Using GitHub Container Registry with GITHUB_TOKEN:**

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Build and push Docker image
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:latest
```

2. **Using Docker Hub:**

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        
      - name: Log in to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          
      - name: Build and push Docker image
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/cicd-demo:latest
```

3. **Using AWS ECR:**

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
        
      - name: Build and push Docker image
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: ${{ steps.login-ecr.outputs.registry }}/cicd-demo:latest
```

### GitLab CI/CD

GitLab CI/CD has built-in integration with GitLab's Container Registry.

**Recommended setup for GitLab CI/CD:**

1. **Using GitLab Container Registry:**

```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
```

2. **Using Docker Hub:**

```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
  script:
    - docker build -t $DOCKERHUB_USERNAME/cicd-demo:$CI_COMMIT_SHORT_SHA .
    - docker push $DOCKERHUB_USERNAME/cicd-demo:$CI_COMMIT_SHORT_SHA
```

3. **Using Google Container Registry:**

```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - echo $GCP_SERVICE_KEY | docker login -u _json_key --password-stdin https://gcr.io
  script:
    - docker build -t gcr.io/$GCP_PROJECT_ID/cicd-demo:$CI_COMMIT_SHORT_SHA .
    - docker push gcr.io/$GCP_PROJECT_ID/cicd-demo:$CI_COMMIT_SHORT_SHA
```

### Jenkins

Jenkins offers flexibility in container registry authentication through credentials.

**Recommended setup for Jenkins Pipeline:**

1. **Using Docker Hub:**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: docker
                    image: docker:latest
                    command:
                    - cat
                    tty: true
                    volumeMounts:
                    - mountPath: /var/run/docker.sock
                      name: docker-sock
                  volumes:
                  - name: docker-sock
                    hostPath:
                      path: /var/run/docker.sock
            '''
        }
    }
    
    stages {
        stage('Build and Push') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                        sh "docker build -t ${DOCKER_USERNAME}/cicd-demo:${env.BUILD_NUMBER} ."
                        sh "docker push ${DOCKER_USERNAME}/cicd-demo:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
```

2. **Using AWS ECR:**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: docker
                    image: docker:latest
                    command:
                    - cat
                    tty: true
                    volumeMounts:
                    - mountPath: /var/run/docker.sock
                      name: docker-sock
                  - name: aws
                    image: amazon/aws-cli
                    command:
                    - cat
                    tty: true
                  volumes:
                  - name: docker-sock
                    hostPath:
                      path: /var/run/docker.sock
            '''
        }
    }
    
    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = '123456789012.dkr.ecr.us-east-1.amazonaws.com/cicd-demo'
    }
    
    stages {
        stage('Build and Push') {
            steps {
                container('aws') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}"
                    }
                }
                
                container('docker') {
                    sh "docker build -t ${ECR_REPOSITORY}:${env.BUILD_NUMBER} ."
                    sh "docker push ${ECR_REPOSITORY}:${env.BUILD_NUMBER}"
                }
            }
        }
    }
}
```

3. **Using Private Registry with TLS:**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: docker
                    image: docker:latest
                    command:
                    - cat
                    tty: true
                    volumeMounts:
                    - mountPath: /var/run/docker.sock
                      name: docker-sock
                    - mountPath: /certs
                      name: registry-certs
                  volumes:
                  - name: docker-sock
                    hostPath:
                      path: /var/run/docker.sock
                  - name: registry-certs
                    secret:
                      secretName: registry-certs
            '''
        }
    }
    
    environment {
        REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'cicd-demo'
    }
    
    stages {
        stage('Build and Push') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'registry-credentials', passwordVariable: 'REGISTRY_PASSWORD', usernameVariable: 'REGISTRY_USERNAME')]) {
                        sh "mkdir -p /etc/docker/certs.d/${REGISTRY}"
                        sh "cp /certs/ca.crt /etc/docker/certs.d/${REGISTRY}/ca.crt"
                        sh "echo ${REGISTRY_PASSWORD} | docker login ${REGISTRY} -u ${REGISTRY_USERNAME} --password-stdin"
                        sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                        sh "docker push ${REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
```

## Best Practices for Registry Authentication

1. **Never hardcode credentials**:
   - Store credentials as secrets/variables in your CI/CD platform
   - Rotate credentials regularly

2. **Use least privilege principles**:
   - Create dedicated service accounts with minimal permissions
   - Limit access to specific repositories

3. **Implement credential helpers**:
   - Use credential helpers for local development
   - Store credentials securely

4. **Consider pull-through caching**:
   - Set up pull-through caches to improve build times
   - Reduce external dependencies

5. **Implement image scanning**:
   - Scan images for vulnerabilities before pushing
   - Set policies to prevent vulnerable images from being deployed

6. **Use immutable tags**:
   - Avoid using 'latest' tag in production
   - Use immutable tags like git SHA or build numbers

## Recommended Registry per Platform

For educational purposes, we recommend:

1. **GitHub Actions**: GitHub Container Registry (ghcr.io)
   - Seamless integration with GitHub
   - Built-in authentication with GITHUB_TOKEN
   - Free for public repositories

2. **GitLab CI/CD**: GitLab Container Registry
   - Tight integration with GitLab
   - Automatic authentication using CI variables
   - Simplified permissions management

3. **Jenkins**: Docker Hub or self-hosted registry
   - Wide compatibility
   - Flexible authentication options
   - Works well with Jenkins credential store

## Security Considerations

1. **Public vs. Private Registries**:
   - Public registries expose your images to everyone
   - Private registries provide control over access
   - Consider the sensitivity of your application when choosing

2. **Token-based Authentication**:
   - Prefer tokens over username/password
   - Implement token expiration and rotation

3. **Network Security**:
   - Use TLS for registry communication
   - Consider network policies to restrict registry access

4. **Audit Logging**:
   - Enable audit logging for registry access
   - Monitor for unauthorized access attempts
