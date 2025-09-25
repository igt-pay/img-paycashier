def shouldPushImage() { return (env.BRANCH_NAME == "main") }

def pushImage(imageName) {
    if (!shouldPushImage()) {
        echo "Skipping push for ${imageName} as this is not the main branch."
        return false
    }
    sh "docker tag ${imageName} igtpaygamdevacr.azurecr.io/${imageName}"
    sh "docker push igtpaygamdevacr.azurecr.io/${imageName}"
    if (params.SharedService in ['lot-ct', 'lot-eu', 'lot-us']) {
        sh "docker tag ${imageName} igtpaysbox.azurecr.io/${imageName}"
        sh "docker push igtpaysbox.azurecr.io/${imageName}"
    } else {
        echo "Skipping sbox push for \"${params.SharedService}\" as it is not flagged as lottery shared service."
    }
    return true
}

pipeline {
    agent {
        label 'docker_build'
    }

    parameters {
        choice name: 'SharedService', choices: [
            'undefined',
            'gam-ct',
            'gam-us',
            'lot-ct',
            'lot-us',
            'lot-eu']
        choice name: 'PatchLevel', choices: [
            '25.3',
            '25.2',
            '25.1', 
            '24.5']
    }

    options {
        buildDiscarder logRotator(numToKeepStr: '5')
    }

    environment {
        OurVersion = "undefined"
        BuildType = 'snapshot'
    }

    stages {
        stage('Prepare environment') {
            when{
                expression { params.SharedService != 'undefined' }
            }
            steps {
                script {
                    env.OurVersion=(sh label: 'Calculate image version', script: readFile('calculate_version.sh'), returnStdout: true).trim()
                }
            }
        }
        stage('Download artefacts') {
            when{
                expression { params.SharedService != 'undefined' }
            }
            steps {
                echo "This step downloads cashier packages"
            }
        }
        stage ('Build docker image') {
            when{
                expression { params.SharedService != 'undefined' }
            }
            steps{
                echo "This step builds cashier image"
            }
        }
    }

    post {
        always {
            cleanWs()
            buildName "$env.OurVersion"
        }
        success {
            script {
                if (shouldPushImage() && env.BuildType == 'release') {
                    currentBuild.setKeepLog(true)
                }
            }
        }
    }
    
}