#!/usr/bin/env bash

# minikube start --memory 14336 --cpus 4
# helm init
# eval $(minikube docker-env)
# cd ~/code
# git clone https://github.com/dharmeshkakadia/presto-kubernetes/

echo --------------
echo REDIS
echo --------------
helm upgrade --install redis stable/redis --set usePassword=false,cluster.enabled=false --namespace redis

echo --------------
echo ANDI
echo --------------
cd andi
# docker build -t andi:demo .
helm upgrade --install andi ./chart --namespace admin \
     --set image.repository=andi,image.tag=demo,replicaCount=1,redis.host=redis-master.redis
cd ..

echo --------------
echo KAFKA
echo --------------

echo --------------
echo REAPER
echo --------------

echo --------------
echo PRESTO
echo --------------
kubectl create ns kdp
kubectl create -n kdp -f presto-kubernetes

echo --------------
echo CARPENTER
echo --------------
cd carpenter
cd ..

echo --------------
echo FORKLIFT
echo --------------
cd forklift
cd ..

echo --------------
echo DISCOVERY-API
echo --------------
# cd discovery-api
# docker build -t api:demo .
# cd ..

echo --------------
echo GENESIS
echo --------------
cd genesis
cd ..

echo --------------
echo STREISAND
echo --------------
cd streisand
cd ..

echo --------------
echo DISCOVERY-STREAMS
echo --------------
cd discovery-streams
cd ..

echo --------------
echo ANDI: $(minikube service andi -n admin --url)
echo --------------
