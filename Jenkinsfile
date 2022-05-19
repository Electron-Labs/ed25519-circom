pipeline {
  agent any
  stages {
    stage('Build/Test') {
      steps {
        sh 'cd $HOME && ./test.sh'
      }
    }

    stage('Done') {
      steps {
        echo 'Tested Successfully '
      }
    }

  }
}