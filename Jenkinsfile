pipeline {
  agent any
  stages {
    stage('Build/Test') {
      steps {
        sh 'cd $HOME && ./test.sh'
        echo '$GIT_BRANCH'
      }
    }

    stage('Done') {
      steps {
        echo 'Tested Successfully '
      }
    }

  }
}