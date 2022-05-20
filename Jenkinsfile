pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh '''export PATH="$PATH:$HOME/.cargo/bin"
dir=echo $JOB_NAME | sed \'s/\\//_/g\'
cd workspace/$dir
npm install
npm run test
'''
      }
    }

  }
}