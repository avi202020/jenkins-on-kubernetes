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

build
deploy
