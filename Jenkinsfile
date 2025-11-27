#!groovy

@Library('github.com/cloudogu/ces-build-lib@feature/153-support-release-of-multiple-major-versions')
import com.cloudogu.ces.cesbuildlib.*

// Creating necessary git objects
git = new Git(this, "cesmarvin")
git.committerName = 'cesmarvin'
git.committerEmail = 'cesmarvin@cloudogu.com'
gitflow = new GitFlow(this, git)
github = new GitHub(this, git)
changelog = new Changelog(this)
Docker docker = new Docker(this)
gpg = new Gpg(this, docker)
goVersion = "1.25.1"
makefile = new Makefile(this)

// Configuration of repository
repositoryOwner = "cloudogu"
repositoryName = "k8s-blueprint-helm"
project = "github.com/${repositoryOwner}/${repositoryName}"
registry = "registry.cloudogu.com"
registry_namespace = "k8s"
k8sTargetDir = "target/k8s"
helmChartDir = "${k8sTargetDir}/helm"
helmChartName = "k8s-blueprint"

// Configuration of branches
productionReleaseBranch = "main"
developmentBranch = "develop"
currentBranch = "${env.BRANCH_NAME}"

node('docker') {
    timestamps {
        stage('Checkout') {
            checkout scm
            make 'clean'
        }

        new Docker(this)
                .image("golang:${goVersion}")
                .mountJenkinsUser()
                .inside("--volume ${WORKSPACE}:/go/src/${project} -w /go/src/${project}")
                        {
                            stage('Generate k8s Resources') {
                                make 'helm-generate'
                                archiveArtifacts "${k8sTargetDir}/**/*"
                            }

                            stage("Lint helm") {
                                make 'helm-lint'
                            }
                        }

        stageAutomaticRelease()
    }
}

void gitWithCredentials(String command) {
    withCredentials([usernamePassword(credentialsId: 'cesmarvin', usernameVariable: 'GIT_AUTH_USR', passwordVariable: 'GIT_AUTH_PSW')]) {
        sh(
            script: "git -c credential.helper=\"!f() { echo username='\$GIT_AUTH_USR'; echo password='\$GIT_AUTH_PSW'; }; f\" " + command,
            returnStdout: true
        )
    }
}

void stageAutomaticRelease() {
    if (gitflow.isReleaseBranch()) {
        String controllerVersion = makefile.getVersion()
        String releaseVersion = "v${controllerVersion}".toString()

        stage('Push Helm chart to Harbor') {
            new Docker(this)
                .image("golang:${goVersion}")
                .mountJenkinsUser()
                .inside("--volume ${WORKSPACE}:/go/src/${project} -w /go/src/${project}")
                        {
                            make 'helm-package'
                            archiveArtifacts "${k8sTargetDir}/**/*"

                            // Push charts
                            withCredentials([usernamePassword(credentialsId: 'harborhelmchartpush', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD')]) {
                                sh ".bin/helm registry login ${registry} --username '${HARBOR_USERNAME}' --password '${HARBOR_PASSWORD}'"

                                sh ".bin/helm push ${helmChartDir}/${helmChartName}-${controllerVersion}.tgz oci://${registry}/${registry_namespace}/"
                            }
                        }
        }

        stage('Finish Release') {
            productionReleaseBranch = makefile.determineGitFlowMainBranch(productionReleaseBranch)
            developmentBranch = makefile.determineGitFlowDevelopBranch()
            gitflow.finishRelease(releaseVersion, productionReleaseBranch, developmentBranch)
        }

        stage('Add Github-Release') {
            releaseId = github.createReleaseWithChangelog(releaseVersion, changelog, productionReleaseBranch)
        }
    }
}

void make(String makeArgs) {
    sh "make ${makeArgs}"
}
