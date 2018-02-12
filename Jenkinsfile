def vagrantUpload = { String branch ->
  if (branch == "origin/master" || branch == "master") {
    return '.'
  } else {
    return '.["post-processors"][0] |= map(select(.type != "vagrant-cloud"))'
  }
}

pipeline {
    agent {
        label 'vagrant'
    }

    environment {
        JQ = vagrantUpload(env.GIT_BRANCH)
    }

    stages {
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
                    sh 'make clean DISTRIBUTION=ubuntu'
                    sh 'make build DISTRIBUTION=ubuntu'
                }
            }
        }
    }
    post {
        always {
           cleanWs()
        }
    }
}
