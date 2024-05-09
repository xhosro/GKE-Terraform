# Project Terraform for Google Kubernetes Engine (GKE)

This Terraform project automates the provisioning of a Kubernetes cluster on Google Cloud Platform (GCP) using Google Kubernetes Engine (GKE). It enables you to quickly set up a production-ready Kubernetes environment with infrastructure as code.

## Prerequisites

Before you begin, make sure you have the following:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- A Google Cloud Platform (GCP) account with appropriate permissions.
- Google Cloud SDK (`gcloud`) installed and configured on your machine.
- Optional: A Google Cloud Storage (GCS) bucket for storing Terraform state.
- kubectl (`kubectl`) installed and configured on your machine

## Getting Started

1. Clone this repository to your local machine:

   ```bash
   git clone <repository_url>


2. Configure default application credentials:

   ```bash
   gcloud auth application-default login


   it will open in browser for autorization

then run terraform init and terraform fmt and terraform validate for debugging syntax and configuration errors

then run terraform plan 
terraform apply -auto--approve


we can visit google console for verify vpc network and kubenrbetes engine
in console in the node part we can find connect 

gcloud container clusters get-credentials primary --zone europe-west1-c --project terraform-422613

but firstly we need to install 

gcloud components install gke-gcloud-auth-plugin  

and then run 
kubectl get svc
show the kubernetes service from default namespace

kubectl get nodes

to demonstrate cluster autoscaling , use nginx image with 2 replicas
the first deployment object
we want to deploy it to the spot instance group 

kubectl apply -f nginx-auto-scale.yaml

kubectl get pods

kubectl describe pod nginx.....


kubctl get nodes 
two addithinnel nodes will be deployed, when they become ready two pods will be able to schedule


so we have 4 nodes and 2  pods

how to use workload identity and grant access to the podes to list gs buckets??

first of all we create a service account resources 

then terraform apply

go to service account google console for verifying

2: 

create service account

go to console and choose a service accounts & IAM

kubectl apply -f kube.yaml

command and args are used to override the default command and arguments that are run when the container starts. In this case, it's running a shell command that keeps the container running (while true; do sleep 30; done;). This is often used to keep the pod running so that you can interact with it, for example, via kubectl exec.

kubectl get pods -n staging

kubectl exec -n staginig -it gcloud-78756cf98-bjv5x -- bash

gloud alpha storage ls

we get error

the caller doesnt have storage.bucket.list access; thats beacause when we omit the service acconu in the depoyment oonject , it will use the default service acconut in that namespace

