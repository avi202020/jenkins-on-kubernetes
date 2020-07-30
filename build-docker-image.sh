#!/usr/bin/env bash

function build() {
    REPO=smpavlenko/my-jenkins-image
    TAG=1.0

    eval $(minikube docker-env)
    docker build -t $REPO:$TAG .
}

build
