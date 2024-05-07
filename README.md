# Project Terraform for Google Kubernetes Engine (GKE)

This Terraform project automates the provisioning of a Kubernetes cluster on Google Cloud Platform (GCP) using Google Kubernetes Engine (GKE). It enables you to quickly set up a production-ready Kubernetes environment with infrastructure as code.

## Prerequisites

Before you begin, make sure you have the following:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- A Google Cloud Platform (GCP) account with appropriate permissions.
- Google Cloud SDK (`gcloud`) installed and configured on your machine.
- Optional: A Google Cloud Storage (GCS) bucket for storing Terraform state.

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




