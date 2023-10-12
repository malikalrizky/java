def DOCKER_IMAGE = "java"
def DOCKER_TAG = "latest"
def CLUSTER = "k3d-mycluster"
pipeline {
    agent any

    stages {
        // stage('Checkout') {
        //     steps {
        //         // Get the code from the source control management (SCM)
        //         checkout scm
        //     }
        // }

        stage('Build Docker Image') {
            steps {
                script {
                sh """
                docker build --cache-from ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                """
              }
            }
        }

        // stage('Push Docker Image') {
        //     steps {
        //         script {
        //         sh """
        //         docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
        //         """
        //       }
        //     }
        // }

        stage('Deploy') {
            steps {
                script {
                sh """
                kubectl apply -f manifest/deployment.yaml --context ${CLUSTER}
                """
              }
            }
        }
    }
}
