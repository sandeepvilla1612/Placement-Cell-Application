pipeline {
  agent any

  environment {
    IMAGE = "YOUR_DOCKERHUB_USER/placement-cell"
    TAG   = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker image') {
      steps {
        sh "docker build -t ${IMAGE}:${TAG} -t ${IMAGE}:latest ."
      }
    }

    stage('Login to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
        }
      }
    }

    stage('Push images') {
      steps {
        sh "docker push ${IMAGE}:${TAG}"
        sh "docker push ${IMAGE}:latest"
      }
    }

    stage('Deploy to remote') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'server-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
          sh """
            chmod 600 $SSH_KEY
            # copy docker-compose (optional) and .env to remote, or have them preplaced
            scp -o StrictHostKeyChecking=no -i $SSH_KEY docker-compose.yml $SSH_USER@your.server.ip:/opt/placement
            scp -o StrictHostKeyChecking=no -i $SSH_KEY .env $SSH_USER@your.server.ip:/opt/placement

            ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@your.server.ip '
              cd /opt/placement
              docker pull ${IMAGE}:latest
              docker-compose down || true
              docker-compose up -d --build
            '
          """
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline finished"
    }
  }
}
