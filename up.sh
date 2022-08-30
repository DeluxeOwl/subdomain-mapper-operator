#!/usr/bin/env bash
# docker build -t nospamplease/monitor-services:v1 .
# docker push nospamplease/monitor-services:v1

docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t nospamplease/monitor-services:v1 --push .

kubectl delete -f shell-operator-pod.yaml

kubectl apply -f shell-operator-pod.yaml