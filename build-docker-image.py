#!/usr/bin/env python2

import os


def exportDockerProperties():
    os.system('eval $(minikube docker-env)')


def buildDockerImage():
    os.system('docker build -t smpavlenko/my-jenkins-image:2.0 .')


exportDockerProperties()
buildDockerImage()
