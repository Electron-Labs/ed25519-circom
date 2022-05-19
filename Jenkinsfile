pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'curl --proto \'=https\' --tlsv1.2 https://sh.rustup.rs -sSf | sh'
        sh 'git clone https://github.com/iden3/circom.git && cd circom && cargo build --release && cargo install --path circom'
        sh 'npm install -g snarkjs. && npm install'
      }
    }

    stage('Test') {
      steps {
        sh '''npm run build --if-present
'''
        sh '''npm test
'''
        sh '''npm run test-scalarmul
'''
        sh '''npm run test-verify
'''
        sh '''npm run test-batch-verify
'''
        sh 'npm run lint'
      }
    }

  }
}