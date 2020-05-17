#!/bin/bash

terraform init
terraform apply
terraform output kubeconfig > ~/.kube/config
terraform output config-map-aws-auth > /tmp/x.yml
aws eks --region us-east-1 update-kubeconfig --name simple-eks
kubectl apply -f /tmp/x.yml
rm /tmp/x.yml

