# Requisites

- An working, and pleeeeeease, not production AWS Account.
- An IAM user with Administrative access.

## Configure Access

- Rename `terraform.tfvars.sample` to `terraform.tfvars` and replace the placeholders with your IAM access and secret keys

## Install aws-iam-authenticator


`curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator &&
chmod +x ./aws-iam-authenticator && 
sudo mv aws-iam-authenticator /usr/local/bin/`


## kubectl and kubeconfig

- It's strongly recommended that you create a backup of your `~/.kube/config` before applying this changes.

`curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && sudo mv kubectl /usr/local/bin/kubectl`

## Apply

`./apply.sh`

## Destroy

`terraform destroy -auto-approve`
