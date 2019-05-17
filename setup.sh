#!/usr/bin/env bash

# minikube start --memory 14336 --cpus 4
# helm init
# eval $(minikube docker-env)
# cd ~/code
# git clone https://github.com/dharmeshkakadia/presto-kubernetes/
# mix hex.organization auth smartcolumbus_os
# export HEX_TOKEN=$(mix hex.organization key smartcolumbus_os generate)

# repos with demo branches:
# - andi
# - carpenter
# - kdp

echo --------------
echo REDIS
echo --------------
helm upgrade --install redis stable/redis --set usePassword=false,cluster.enabled=false --namespace redis

echo --------------
echo ANDI
echo --------------
docker build -t andi:demo ./andi
helm upgrade --install andi ./andi/chart --namespace admin \
     --set image.repository=andi,image.tag=demo,replicaCount=1,redis.host=redis-master.redis

echo --------------
echo KAFKA
echo --------------

echo --------------
echo REAPER
echo --------------

echo --------------
echo PRESTO
echo --------------
helm upgrade --install kdp ./kdp/charts --namespace kdp

echo --------------
echo CARPENTER
echo --------------
docker build -t carpenter:demo --build-arg HEX_TOKEN=$HEX_TOKEN carpenter
helm upgrade --install carpenter ./carpenter/chart \
     --namespace streaming-services \
     --set image.repository=carpenter,image.tag=demo \
     --set redis.host=redis-master.redis \
     --set presto.url=http://presto.kdp:8080

echo --------------
echo FORKLIFT
echo --------------

echo --------------
echo DISCOVERY-API
echo --------------

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
echo PRESTO: $(minikube service presto -n kdp --url)
echo ANDI: $(minikube service andi -n admin --url)
echo --------------
