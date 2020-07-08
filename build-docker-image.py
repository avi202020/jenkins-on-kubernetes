#!/usr/bin/env python2

import os


def exportDockerProperties():
    os.system('eval $(minikube docker-env)')


exportDockerProperties()
