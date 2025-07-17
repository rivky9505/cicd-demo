pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: python
                    image: python:3.9-slim
                    command:
                    - cat
                    tty: true
                  - name: docker
                    image: docker:latest
                    command:
                    - cat
                    tty: true
                    volumeMounts:
                    - mountPath: /var/run/docker.sock
                      name: docker-sock
                  - name: kubectl
                    image: bitnami/kubectl:latest
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
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'cicd-demo'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test') {
            steps {
                container('python') {
                    sh 'pip install -r requirements.txt'
                    sh 'python -m pytest test_app.py -v'
                }
            }
        }
        
        stage('Build and Push Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker-registry-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo ${DOCKER_PASSWORD} | docker login ${DOCKER_REGISTRY} -u ${DOCKER_USERNAME} --password-stdin"
                        sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                        sh "docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                expression { return env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master' }
            }
            steps {
                container('kubectl') {
                    sh "mkdir -p ~/.kube && echo '${KUBECONFIG}' > ~/.kube/config"
                    sh '''
                    cat <<EOF > deployment.yaml
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
                            image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                            ports:
                            - containerPort: 5000
                            env:
                            - name: ENVIRONMENT
                              value: production
                            - name: APP_VERSION
                              value: ${IMAGE_TAG}
                    ---
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
                      type: ClusterIP
                    EOF
                    '''
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }
}
