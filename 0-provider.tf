provider "google" {
    project = "terraform-422613"
    region = "eu-west1" # Belgium
}

terraform {
    backend "gcs" {
      bucket = "bucket-backend-terraform-gcp"
      prefix = "terraform/state"
    }

    required_providers {
      google = {
        source = "hashicorp/google"
        version = "~> 4.0"
      }
    }  
}

# in new project we must enable APIs
resource "google_project_service" "compute" { 
    service = "compute.googleapis.com"
}

resource "google_project_service" "container"{ 
    service = "container.googleapis.com"
}


