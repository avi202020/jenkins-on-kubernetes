#!/usr/bin/env bash

function validate() {
    echo "Checking if Minikube is running"
    if [ $(minikube status --format "{{.Host}}|{{.Kubelet}}|{{.APIServer}}") != "Running|Running|Running" ];
    then
        echo "Minikube is not running. Start Minikube with 'minikube start' command"
        exit
    fi
}

function build() {
    echo "Building docker container"
    REPO=smpavlenko/my-jenkins-image
    TAG=1.0

    eval $(minikube docker-env)
    docker build -t $REPO:$TAG .
}

function deploy() {
    echo "Deploying on Kubernetes"
    kubectl apply -f k8s/jenkins-deployment.yaml
    kubectl apply -f k8s/jenkins-rbac.yaml
    kubectl apply -f k8s/jenkins-service.yaml
}

function config() {
    echo "Configuring Jenkins"
    MINIKUBE_IP=$(minikube ip)
    TARGET_PORT=$(kubectl get service -o json | jq -r '.items[] | select (.metadata.name=="kubernetes") | .spec.ports[].targetPort')
    JENKINS_POD_IP=$(kubectl get pods -o json | jq -r '.items[] | select (.metadata.labels.app=="jenkins") | .status.podIP')
    SERVER_URL="https://$MINIKUBE_IP:$TARGET_PORT"
    JENKINS_URL="http://$JENKINS_POD_IP:8080"

    PWD=$(pwd)
    rm -rf $PWD/dest
    mkdir -p $PWD/dest/var/jenkins_home/jobs/test1;

    cp $PWD/var/jenkins_home/config.xml $PWD/dest/var/jenkins_home/config.xml
    cp $PWD/var/jenkins_home/jobs/test1/config.xml $PWD/dest/var/jenkins_home/jobs/test1/config.xml

    sed -i "" "s|{JENKINS_URL}|$JENKINS_URL|g" $PWD/dest/var/jenkins_home/config.xml
    sed -i "" "s|{SERVER_URL}|$SERVER_URL|g" $PWD/dest/var/jenkins_home/config.xml

    JENKINS_POD_NAME=$(kubectl get pods -o json | jq -r '.items[] | select (.metadata.labels.app=="jenkins") | .metadata.name')
    kubectl cp dest/var $JENKINS_POD_NAME:/
}

function restart() {
    echo "Restarting Jenkins"
    MINIKUBE_IP=$(minikube ip)
    JENKINS_PORT=$(kubectl get service -o json | jq -r '.items[] | select (.metadata.name=="jenkins") | .spec.ports[].nodePort')
    JENKINS_UI_URL="http://$MINIKUBE_IP:$JENKINS_PORT"

    curl -o dest/jenkins-cli.jar -O -L  $JENKINS_UI_URL/jnlpJars/jenkins-cli.jar
    java -jar dest/jenkins-cli.jar -s $JENKINS_UI_URL/ restart

    echo "Jenkins is reachable by $JENKINS_UI_URL"
}

validate
build
deploy
config
restart