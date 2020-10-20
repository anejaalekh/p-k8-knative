#!/bin/bash

figlet HELM

export PATH=/bin:/usr/bin:/usr/local/bin
curl -fsSL -o get_helm3.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod +x get_helm3.sh
./get_helm3.sh


