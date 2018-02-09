def vagrantUpload = { String branch ->
  if (branch == "origin/master" || branch == "master") {
    return '.'
  } else {
    return '.'
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
        stage('Ubuntu') {
            steps {
                withCredentials([string(credentialsId: 'vagrantcloud token', variable: 'VAGRANTCLOUD_TOKEN')]) {
                    sh 'echo "${JQ}"'
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
