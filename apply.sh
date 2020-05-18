#!/bin/bash

build-jenkins() {
  cd jenkins
  docker build -t custom-jenkins .
  cd ..
}

apply-terraform(){
  terraform init
  terraform apply -auto-approve
}

kubectl-setup(){
  terraform output kubeconfig > ~/.kube/config
  terraform output config-map-aws-auth > /tmp/x.yml
  aws eks --region us-east-1 update-kubeconfig --name simple-eks
  kubectl apply -f /tmp/x.yml
  rm /tmp/x.yml
}

start-jenkins(){
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 576962245852.dkr.ecr.us-east-1.amazonaws.com
    docker build -t custom-jenkins .
    docker tag custom-jenkins:latest 576962245852.dkr.ecr.us-east-1.amazonaws.com/custom-jenkins:latest
    docker push 576962245852.dkr.ecr.us-east-1.amazonaws.com/custom-jenkins:latest
    
    kubctl apply -f jenkins/jenkins.yml
}

build-jenkins
apply-terraform
kubectl-setup
start-jenkins