pipeline {
  agent any
  stages {
    stage('Testing Environment variable') {
      steps {
        echo '$GIT_BRANCH'
        sh 'echo "$GIT_BRANCH"'
      }
    }

  }
}