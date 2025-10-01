def shouldPushImage() { return (env.BRANCH_NAME == "main" && params.SharedService != 'undefined') }

def pushImage(imageName) {
    if (!shouldPushImage()) {
        echo "Skipping push for ${imageName}."
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

    stages {
        stage('Prepare environment') {
            steps {
                script {
                    env.OurVersion = "undefined"
                    if (params.SharedService != 'undefined') {
                        env.OurVersion = sh(label: 'Calculate image version', returnStdout: true, script: readFile('calculate_version.sh')).trim()
                        env.OurVersion += "_${params.PatchLevel}"
                    }
                }
            }
        }
        stage('Download artefacts') {
            when{
                expression { params.SharedService != 'undefined' }
            }
            steps {
                script {
                    sh 'mkdir -p artefacts'
                    for (cli_version in readFile("Latest/paycashier-${params.SharedService}.versions").split('\n')){
                        cli = cli_version.split(' ')[0].trim()
                        ver = cli_version.split(' ')[1].trim()
                        echo "cli: \"${cli}\", ver: \"${ver}\""
                        if (ver.startsWith("22.0.")) {
                            sh "cp -v /igt/pay/Build/Resources/CashierApp/${cli}/${ver}/cashier${cli}.war artefacts/"
                        } else {
                            sh "$MVN dependency:copy -U -B -Dartifact=\"com.igt.pay:cashierapp:${ver}:war:cashier${cli}\" -DoutputDirectory=artefacts -Dmdep.stripVersion=true"
                            sh "mv -v artefacts/cashierapp-cashier${cli}.war artefacts/cashier${cli}.war"
                        }
                    }
                }
            }
        }
        stage ('Build docker image') {
            when{
                expression { params.SharedService != 'undefined' }
            }
            steps{
                sh "docker buildx build --build-arg base_version=${params.PatchLevel} -t igtpay/paycashier-${params.SharedService}:${env.OurVersion} ."
                pushImage("igtpay/paycashier-${params.SharedService}:${env.OurVersion}")
            }
        }
    }

    post {
        always {
            cleanWs()
            buildName "${params.SharedService} ${params.PatchLevel} #${BUILD_NUMBER}"
            buildDescription "${env.OurVersion}"
        }
        success {
            script {
                if (shouldPushImage()) {
                    currentBuild.setKeepLog(true)
                }
            }
        }
    }
    
}