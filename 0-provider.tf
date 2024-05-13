provider "google" {
  project = var.gcp_projectproject
  region  = var.gcp_region
  #credentials = file(var.gcp_svc_key)
}

terraform {
  backend "gcs" {
    bucket = var.gcs_bucket
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# in new project we must enable APIs
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}


