#!/usr/bin/env bash

eval $(minikube docker-env)
docker build -t smpavlenko/my-jenkins-image:2.0 .
