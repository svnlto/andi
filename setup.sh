#!/usr/bin/env bash

eval $(minikube docker-env)

cd andi
docker build -t andi:demo .
helm upgrade --install andi ./chart --set image.repository=andi,image.tag=demo,replicaCount=1 --namespace admin
cd ..

cd discovery-api
docker build -t api:demo .
# TODO helm
cd ..
