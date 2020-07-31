#!/usr/bin/env bash

function build() {
    REPO=smpavlenko/my-jenkins-image
    TAG=1.0

    eval $(minikube docker-env)
    docker build -t $REPO:$TAG .
}

function deploy() {
    kubectl apply -f jenkins-deployment.yaml
    kubectl apply -f jenkins-rbac.yaml
    kubectl apply -f jenkins-service.yaml
}

function config() {
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

    JENKINS_POD_NAME=$(kubectl get pod -o json | jq -r .items[0].metadata.name)
    kubectl cp dest/var $JENKINS_POD_NAME:/
}


build
deploy
config