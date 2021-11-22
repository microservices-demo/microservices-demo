pipeline {
  agent any
  stages {
    stage('git scm update') {
      steps {
        git url: 'https://github.com/micro-amazon/admin.git', branch: 'main'
      }
    }
    stage('docker build and push') {
      steps {
        sh '''
        docker build -t mini-amazon-admin/admin .
        docker push zwan2/mini-amazon-admin:admin
        '''
      }
    }
    stage('deploy kubernetes') {
      steps {
        sh '''
        kubectl create deployment admin-prod --image=zwan2/mini-amazon-admin:admin
        kubectl expose deployment admin-prod --type=LoadBalancer --port=8080 \
                                               --target-port=80 --name=pl-admin-prod-svc
        '''
      }
    }
  }
}