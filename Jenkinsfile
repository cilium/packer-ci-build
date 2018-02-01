pipeline {
    agent {
        label 'vagrant'
    }
    environment {
        JQ = '.["post-processors"][0] |= map(select(.type != "vagrant-cloud"))'
    }

    stages {
        stage('Validate Upload'){
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/master';
                }
            }
            steps {
                script {
                    JQ = "."
                }
            }
        }
        stage('Opensuse') {
            steps {
                sh 'printenv'
                withCredentials([string(credentialsId: 'vagrantcloud token', variable: 'VAGRANTCLOUD_TOKEN')]) {
                    sh 'echo ${JQ}'
                    sh 'git submodule update --init --recursive'
                    sh 'make build DISTRIBUTION=opensuse'
                }
            }
        }
        stage('Ubuntu') {
            steps {
                withCredentials([string(credentialsId: 'vagrantcloud token', variable: 'VAGRANTCLOUD_TOKEN')]) {
                    sh 'echo "${JQ}"'
                    sh 'make build DISTRIBUTION=ubuntu'
                }
            }
        }
    }
}
