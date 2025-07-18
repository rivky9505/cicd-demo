pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Test') {
      agent {
        docker {
          image 'python:3.9-slim'
        }
      }
      steps {
        sh 'pip install -r requirements.txt'
        sh 'pytest --maxfail=1 --disable-warnings -q'
      }
    }

    stage('Build') {
      steps {
        script {
          docker.build('cicd-demo:latest')
        }
      }
    }
  }
}