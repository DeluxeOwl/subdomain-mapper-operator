#!/usr/bin/env bash
# docker build -t nospamplease/subdomain-mapper:v1 .
# docker push nospamplease/subdomain-mapper:v1

docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t nospamplease/subdomain-mapper:v1 --push .

kubectl delete -f subdomain-mapper-operator.yaml

kubectl apply -f subdomain-mapper-operator.yaml