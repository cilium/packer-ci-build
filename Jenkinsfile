def vagrantUpload = { String branch ->
  if (branch == "origin/master" || branch == "master") {
    return '.'
  } else {
    return 'del(."post-processors"[])'
  }
}

pipeline {
    agent {
        label 'baremetal'
    }
    options {
        timeout(time: 400, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }

    environment {
        JQ = vagrantUpload(env.GIT_BRANCH)
        VAGRANTCLOUD_TOKEN = credentials('vagrantcloud token')
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = credentials('AWS_DEFAULT_REGION')
        CILIUM_BRANCH = "${params.CiliumBranch}"
    }

    stages {
        stage('OpenSuse') {
            steps {
                sh 'make clean DISTRIBUTION=opensuse'
                sh 'make build DISTRIBUTION=opensuse'
            }
        }

        stage('Ubuntu') {
            steps {
                sh 'echo "${JQ}"'
                sh 'echo "AWS region=${AWS_DEFAULT_REGION}"'
                sh 'make clean DISTRIBUTION=ubuntu'
                sh 'make build DISTRIBUTION=ubuntu'
                sh 'make clean NAME_PREFIX="dev-" NAME_SUFFIX="-dev" DISTRIBUTION=ubuntu'
                sh 'make build NAME_PREFIX="dev-" NAME_SUFFIX="-dev" DISTRIBUTION=ubuntu'
            }
        }
    }
    post {
        always {
           cleanWs()
        }
    }
}
