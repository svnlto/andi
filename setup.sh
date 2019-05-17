#!/usr/bin/env bash

# minikube start --memory 14336 --cpus 4
# helm init
# eval $(minikube docker-env)
# cd ~/code

PLATFORM_IP=$(minikube ip)

echo --------------
echo REDIS
echo --------------
helm install --name redis stable/redis --set usePassword=false,cluster.enabled=false --namespace redis

echo --------------
echo ANDI
echo --------------

cd andi
docker build -t andi:demo .
helm upgrade --install andi ./chart --set image.repository=andi,image.tag=demo,replicaCount=1,redis.host=redis-master.redis --namespace admin
cd ..

ANDI_PORT=$(kubectl get svc -n admin | tail -1 | awk '{print $5}' | cut -d: -f2 | cut -d/ -f1)

echo --------------
echo KAFKA
echo --------------

echo --------------
echo REAPER
echo --------------

echo --------------
echo PRESTO
echo --------------

echo --------------
echo CARPENTER
echo --------------

echo --------------
echo FORKLIFT
echo --------------

echo --------------
echo DISCOVERY-API
echo --------------

# cd discovery-api
# docker build -t api:demo .
# cd ..

echo --------------
echo GENESIS
echo --------------

echo --------------
echo STREISAND
echo --------------

echo --------------
echo DISCOVERY-STREAMS
echo --------------

echo --------------
echo ANDI: http://${PLATFORM_IP}:${ANDI_PORT}
echo --------------
