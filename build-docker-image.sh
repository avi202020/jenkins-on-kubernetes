#!/usr/bin/env bash

REPO=smpavlenko/my-jenkins-image
TAG=1.0

eval $(minikube docker-env)
docker build -t $REPO:$TAG .
