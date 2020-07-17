#!/usr/bin/env bash

kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-rbac.yaml
kubectl apply -f jenkins-service.yaml
