# a service account is a special kind of account used by an application or compute workload, rather than a person.
# The service account maneged by IAM
# to follow the best practices ,we need to create a dedicated service account
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

# first node is general without tains to be able to run cluster componentssuch as DNS
resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.primary.id
  node_count = 1 # 

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false      # A boolean that represents whether or not the underlying node VMs are preemptible.
    machine_type = "e2-small" # large instances and small nodes, since there are a lot of components that need to be deployed such as fluent bit, node exporter,


    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


# 
resource "google_container_node_pool" "spot" {
  name    = "spot"
  cluster = google_container_cluster.primary.id

  autoscaling {
    min_node_count    = 1
    max_node_count    = 10
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true # use much cheaper VM for kubernetes nodes # usecase for batch jobs and some data pipelines
    machine_type = "e2-small"

    labels = {
      team = "devops"
      role = "spot"
    }

    # such nodes must have taints to avoid accidental scheduling, your deployment or pod object must tolerate those taints.
    taint {
      key    = "instance_type"
      effect = "NO_SCHEDULE"
      value  = "spot"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
} 