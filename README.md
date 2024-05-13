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


3. run terraform init and terraform fmt and terraform validate for debugging syntax and configuration errors
- then run terraform plan 

   ```bash
   terraform apply 


4. we can visit google console for verify vpc network and Kubernetes engine
- in console in the node part we can find connect 

    ```bash
   gcloud container clusters get-credentials primary --zone europe-west1-c --project terraform-422613

- before we need to install:

   ```bash
   gcloud components install gke-gcloud-auth-plugin  

5. show the kubernetes service and nodes from default namespace

    ```bash
    kubectl get svc
    kubectl get nodes

6. to demonstrate cluster autoscaling , use nginx image with 2 replicas
- the first deployment object we want to deploy it to the spot instance group 

     ```bash 
     kubectl apply -f nginx-auto-scale.yaml
     kubectl get pods
     kubectl describe pod nginx-...
     kubectl get nodes 

- two additional nodes will be deployed, when they become ready two pods will be able to schedule
- so we have 4 nodes and 2 pods



7. how to use workload identity and grant access to the pods to list gs buckets??
- first of all we create a service account resources 
- then run
    ```bash
    terraform apply

- go to service account google console for verifying
- then run
    ```bash 
    kubectl apply -f kube.yaml

- command and args are used to override the default command and arguments that are run when the container starts. In this case, it's running a shell command that keeps the container running (while true; do sleep 30; done;). This is often used to keep the pod running so that you can interact with it, for example, via kubectl exec.
   ```bash 
   kubectl get pods -n staging

   kubectl exec -n staginig -it gcloud-78756cf98-bjv5x -- bash

   gcloud alpha storage ls

- we get error

- the caller doesnt have storage.bucket.list access; thats because when we omit the service account in the deployment object, 
- it will use the default service acconut in that namespace



- it should impersonate the gcp service account and get access to the buckets

   ```bash 
   kubectl get sa -n staging
    
- NAME        SECRETS   AGE
- default     0         75m
- service-1   0         52s

   ```bash 
   kubectl get pods -n staging
- NAME                      READY   STATUS    RESTARTS   AGE
    ```bash 
   gcloud-759d54f847-f57dp   1/1     Running   0          72s

   kubectl exec -n staging -it gcloud-759d54f847-f57dp  -- bash


  root@gcloud-759d54f847-f57dp:/# gcloud alpha storage ls
  gs://bucket-backend-terraform-gcp/


- we have just one bucket for backend terraform



8. Deploy the nginx ingress controller using the helm

- first add ingress-nginx repository

   ```bash 
   helm repo add ingress-nginx  \
   > https://kubernetes.github.io/ingress-nginx


- update the helm index
   
   ```bash 
   helm repo update

- search for ingress-nginx  

    ```bash  
    helm search repo nginx

NAME                                            CHART VERSION   APP VERSION                                         
ingress-nginx/ingress-nginx                     4.10.1          1.10.1      

- to override some default variables 
- create the nginx-values
- all options on the nginx website
   ```bash 
   helm install my-ing ingress-nginx/ingress-nginx \
   --namespace ingress \
   --version 4.10.1 \
   -f nginx-values.yaml \
   --create-namespace


NAME: my-ing
LAST DEPLOYED: Sat May 11 02:21:32 2024
NAMESPACE: ingress
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the load balancer IP to be available.
You can watch the status by running 'kubectl get service --namespace ingress my-ing-ingress-nginx-controller --output wide --watch'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: external-nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls


  kubectl get pods -n ingress

  kubectl get svc -n ingress
NAME                                        TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)                      AGE
my-ing-ingress-nginx-controller             LoadBalancer   10.22.5.53    34.78.22.124   80:32502/TCP,443:31998/TCP   4m31s
my-ing-ingress-nginx-controller-admission   ClusterIP      10.22.4.252   <none>         443/TCP                      4m31s
my-ing-ingress-nginx-controller-metrics     ClusterIP      10.22.8.156   <none>         10254/TCP                    4m31s

create third yaml file
kube3.yaml

kubectl apply -f kube3.yaml

verify if you set up ingress correctly

kubectl get ingressclass

kubectl get ing

kubectl get svc -n ingress

the final step to this ingress work , is to create DNS A record in your dns provider

