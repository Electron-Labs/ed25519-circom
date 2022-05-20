pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh '''export PATH="$PATH:$HOME/.cargo/bin"
cd $JOB_NAME
npm install
npm run test
'''
      }
    }

  }
}