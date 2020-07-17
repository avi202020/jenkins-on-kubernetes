#!/usr/bin/env bash

kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-rbac.yaml
kubectl apply -f jenkins-service.yaml

MINIKUBE_IP=$(minikube ip)
JENKINS_PORT=$(kubectl get service -o json | jq -r '.items[] | select (.metadata.name=="jenkins") | .spec.ports[].nodePort')
TARGET_PORT=$(kubectl get service -o json | jq -r '.items[] | select (.metadata.name=="kubernetes") | .spec.ports[].targetPort')
JENKINS_POD_IP=$(kubectl get pods -o json | jq -r '.items[] | select (.metadata.labels.app=="jenkins") | .status.podIP')
JENKINS_UI_URL="http://$MINIKUBE_IP:$JENKINS_PORT"
echo $JENKINS_UI_URL
