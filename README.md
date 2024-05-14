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


# Enabling Workload Identity and Granting Access to GCS Buckets in Kubernetes

This guide provides instructions on how to enable Workload Identity in a Kubernetes cluster and grant access to pods to list Google Cloud Storage (GCS) buckets.

## Prerequisites

- Access to a Google Cloud Platform (GCP) project with appropriate permissions to create service accounts and assign roles.
- `kubectl` CLI installed and configured to use the target Kubernetes cluster.
- Terraform CLI installed.

## Steps

1. **Create a Service Account**:
   - Create a Google Cloud service account with the necessary permissions to list GCS buckets. For example, grant the `roles/storage.objectViewer` role to the service account.

2. **Configure Workload Identity**:
   - Associate the Kubernetes service account used by your pods with the Google Cloud service account created in step 1. This enables Workload Identity, allowing pods to use the service account's permissions to access GCP services.

3. **Apply Terraform Configuration**:
   - Apply the Terraform configuration to create the necessary resources, including the Kubernetes service account.

4. **Apply Kubernetes Configuration**:
   - Apply the Kubernetes configuration to deploy your pods with the associated service account.

## Usage

1. Apply Terraform Configuration:
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
    
   kubectl get pods -n staging

   kubectl exec -n staging -it gcloud-759d54f847-f57dp  -- bash


  root@gcloud-759d54f847-f57dp:/# gcloud alpha storage ls
  gs://bucket-backend-terraform-gcp/


- we have just one bucket for backend terraform





# Setting Up Nginx Ingress Controller on Kubernetes

This guide walks through the process of deploying an Nginx Ingress Controller on a Kubernetes cluster using Helm. The Nginx Ingress Controller is used to manage external access to Kubernetes services via HTTP and HTTPS.

## Prerequisites

- Access to a Kubernetes cluster
- `kubectl` CLI installed and configured to use the target cluster
- Helm installed

## Deploying Nginx Ingress Controller

1. Add the Ingress-Nginx Helm repository:

    ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ```

2. Update the Helm repository index:

    ```bash
    helm repo update
    ```

3. Search for the Ingress-Nginx Helm chart:

    ```bash
    helm search repo nginx
    ```

4. Create a values file (`nginx-values.yaml`) to override default variables. Refer to the [Nginx Ingress Controller documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/) for available options.

5. Install the Ingress-Nginx Helm chart:

    ```bash
    helm install my-ing ingress-nginx/ingress-nginx \
    --namespace ingress \
    --version 4.10.1 \
    -f nginx-values.yaml \
    --create-namespace
    ```

6. Verify the installation:

    ```bash
    kubectl get pods -n ingress
    kubectl get svc -n ingress
    ```

## Configuring Ingress

1. Create Ingress resources to define how external traffic should be routed to your Kubernetes services. Here's an example:

    ```yaml
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
      tls:
        - hosts:
          - www.example.com
          secretName: example-tls
    ```

2. Apply the Ingress resource to the cluster:

    ```bash
    kubectl apply -f ingress.yaml
    ```

3. Verify the Ingress setup:

    ```bash
    kubectl get ingressclass
    kubectl get ingress
    ```

## DNS Configuration

1. Create a DNS A record in your DNS provider pointing to the external IP address of the Nginx Ingress Controller service.

## Conclusion

By following these steps, you've successfully deployed and configured an Nginx Ingress Controller on your Kubernetes cluster. This allows you to manage external access to your Kubernetes services efficiently.
