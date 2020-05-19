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
    cp ~/.kube/config /tmp/config-before
    terraform output kubeconfig > ~/.kube/config
    cp ~/.kube/config /tmp/config-terraform
    aws eks --region us-east-1 update-kubeconfig --name simple-eks
    cp ~/.kube/config /tmp/config-eks
    terraform output config-map-aws-auth > /tmp/x.yml
    kubectl apply -f /tmp/x.yml
    rm /tmp/x.yml
}

start-jenkins(){
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 576962245852.dkr.ecr.us-east-1.amazonaws.com
    docker tag custom-jenkins:latest 576962245852.dkr.ecr.us-east-1.amazonaws.com/custom-jenkins:latest
    docker push 576962245852.dkr.ecr.us-east-1.amazonaws.com/custom-jenkins:latest
    
    kubectl apply -f jenkins/jenkins-deployment.yml
    kubectl apply -f jenkins/jenkins-service.yml
}

kafka-setup(){
    kubectl apply -f kafka/zookeeper.yml
    kubectl apply -f kafka/kafka-broker1.yml
    kubectl apply -f kafka/kafka-service.yml
    #KAHN=$(kubectl describe svc kafka | grep "LoadBalancer Ingress" | awk -F ": " '{print $2}')
    #echo "$KAHN"
    #kubectl create configmap kafka-config --from-literal=kahn=
}

build-jenkins
apply-terraform
kubectl-setup
start-jenkins
kafka-setup