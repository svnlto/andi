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
# - forklift
# - kdp
# - streaming-service

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
echo STRIMZI
echo --------------
kubectl apply -f streaming-service/k8s
helm repo add strimzi http://strimzi.io/charts
helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
     --version 0.08.0 \
     -f streaming-service/strimzi-config.yml \
     --namespace strimzi

echo --------------
echo KAFKA
echo --------------
helm upgrade --install streaming-service-kafka-prime ./streaming-service/chart \
     --namespace streaming-prime --timeout 600 \
     --set kafka.defaultReplicas=1,kafka.defaultPartitions=20 \
     --set kafka.storageType=ephemeral,zookeeper.storageType=ephemeral \
     --set kafka.resources.requests.cpu=600m,kafka.resources.requests.memory=4Gi \
     --set kafka.resources.limits.cpu=1000m,kafka.resources.limits.memory=6Gi

echo --------------
echo REAPER
echo --------------
docker build -t reaper:demo ./reaper

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
docker build -t forklift:demo --build-arg HEX_TOKEN=$HEX_TOKEN forklift
helm upgrade --install forklift ./forklift/chart \
     --namespace streaming-services \
     --set image.repository=forklift,image.tag=demo \
     --set redis.host=redis-master.redis

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
