pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'curl --proto \'=https\' --tlsv1.2 https://sh.rustup.rs -sSf -y | sh'
        sh 'cd circom && cargo build --release && cargo install --path circom'
      }
    }

    stage('Test') {
      steps {
        sh 'cd $HOME/workspace/ed25519-circom_gaurav-ci && npm install && npm test'
        sh '''cd $HOME/workspace/ed25519-circom_gaurav-ci  && npm run test-scalarmul
'''
        sh '''cd $HOME/workspace/ed25519-circom_gaurav-ci  && npm run test-verify
'''
        sh '''cd $HOME/workspace/ed25519-circom_gaurav-ci  && npm run test-batch-verify
'''
        sh 'cd $HOME/workspace/ed25519-circom_gaurav-ci  && npm run lint'
      }
    }

  }
}