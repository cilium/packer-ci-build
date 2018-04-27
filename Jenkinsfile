def vagrantUpload = { String branch ->
  if (branch == "origin/master" || branch == "master") {
    return '.'
  } else {
    return 'del(."post-processors"[])'
  }
}

pipeline {
    agent {
        label 'vagrant'
    }
    options {
        timeout(time: 400, unit: 'MINUTES')
        timestamps()
    }

    environment {
        JQ = "."
        VAGRANTCLOUD_TOKEN = credentials('vagrantcloud token')
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        /* AWS_DEFAULT_REGION = "us-west-2" */
        CILIUM_BRANCH = "${params.CiliumBranch}"
    }

    stages {
        /* stage('OpenSuse') { */
        /*     steps { */
        /*         sh 'git submodule update --init --recursive' */
        /*         sh 'make clean DISTRIBUTION=opensuse' */
        /*         sh 'make build DISTRIBUTION=opensuse' */
        /*     } */
        /* } */
        stage('Ubuntu') {
            steps {
                sh 'echo "${JQ}"'
                sh 'make clean DISTRIBUTION=ubuntu'
                sh 'make build DISTRIBUTION=ubuntu'
            }
        }
    }
    post {
        always {
           cleanWs()
        }
    }
}
