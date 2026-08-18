pipeline {
    agent any

    triggers {
        // Trigger a build on every push to the repository
        githubPush()
    }

    environment {
        IMAGE_NAME = "heroku"
        IMAGE_TAG = "latest"
        DOCKER_USER = "$name"
        DOCKER_PASS = 'Docker-hub'
        KUBE_NAMESPACE = "jenkins"
        KUBE_CREDENTIALS = "kubernetes"
    }

    stages {
        stage('Start Pipeline') {
            steps {
                script {
                    // Send the initial email at the start
                    mail bcc: '', body: 'Pipeline automatique a commencé.', subject: 'Pipeline Started', to: 'dulcinemfo@gmail.com'
                    echo ' Pipeline automatique a commencé  .'
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Mystoche/Heroku.git'
            }
        }


        stage('Run Html Tests') {
            steps {
		sh 'npx htmlhint ./ || echo "HTMLHint non critique"'
            }
        }

        stage('Js Test') {
            steps {
		sh 'npx eslint ./ || echo "ESLint non critique"'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'Docker-hub', variable: 'DOCKER_PASS')]) {
                    echo "Authentification Docker Hub"
                    sh "echo $DOCKER_PASS | docker login -u ${DOCKER_USER} --password-stdin"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube-Scanner';
                    withSonarQubeEnv() {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectName=pawapay \
                            -Dsonar.projectKey=pawapay
                        """
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
                }
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                sh '''
                    trivy fs . > trivyfs.txt
                    cat trivyfs.txt
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    kubeconfig(
                        caCertificate: '',
                        credentialsId: 'kubernetes',
                        serverUrl: 'https://ip:8443'
                    ) {
                        sh "kubectl apply -f deployment.yaml -n ${KUBE_NAMESPACE}"
                    }
                }
            }
        }
    }

    post {
        success {
            mail bcc: '', body: 'Pipeline succeeded', subject: 'Pipeline Success', to: 'dulcinemfo@gmail.com'
            echo 'Pipeline executed successfully!'
        }
        failure {
            mail bcc: '', body: 'Pipeline failed', subject: 'Pipeline Failure', to: 'dulcinemfo@gmail.com'
            echo 'Pipeline failed. Check the logs!'
        }
    }
}
