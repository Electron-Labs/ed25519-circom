pipeline {
  agent any
  stages {
    stage('Build/Test') {
      steps {
        sh 'cd $HOME && ./test.sh'
        sh 'echo "Testd"'
      }
    }

  }
}