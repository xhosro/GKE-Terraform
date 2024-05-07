# controle plane of the cluster

resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = "eu-west1-a" #region or availability zone # choosing at least 2 avalibility zones for kubernetes nodes 
  initial_node_count       = 1
  remove_default_node_pool = true # we will create additional instances groups for kubernetes cluster.
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.main.self_link
  logging_service          = "logging.googleapis.com/kubernetes"    # it will high cost 
  monitoring_service       = "monitoring.googleapis.com/kubernetes" # if you want prometeus; you can disable it 
  networking_mode          = "VPC_NATIVE"                           # or Routes # benefits of VPC-native clusters

  # optional, if you want multi-zonal cluster 
  node_locations = [
    "eu-west1-b"
  ]

  # There are many diffrent addons that you can disable or enable, for example you can deploy istio service mesh 
  addons_config {
    #if you plan to use nginx ingress or plain load balancers
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    
  }

  # mange your kubernetes cluster upgrades
  # you never be able to completely disable upgrades for the kubernetes control nodes, however you can disable it for nodes
  release_channel {
    channel = "REGULAR"
  }

  # you can substitue this with variables and data objects
  # you need to replace with your project id
  workload_identity_config {
    workload_pool = "terraform-422613.svc.id.goog"
  }

  # provide the names of the secondary ranges for the pods and then for cluster ips
  ip_allocation_policy {
    cluster_secondary_range_name  = "kubernetes-pod-range"
    services_secondary_range_name = "kubernetes-service-range"
  }

  # make this cluster private
  private_cluster_config {
    enable_private_endpoint = false # if you have a VPN setup or use bastion host to connect to the kubernetes cluster = true
    # otherwise keep it false to be able access to GKE from your computers
    enable_private_nodes   = true             # use only private IPs from our private subnet for k8s nodes
    master_ipv4_cidr_block = "192.168.0.0/28" #cidr range for the control plane
    # they will create a control plane in their network and establish peering connect to youur VPC
  }

  # you can specify the cidr ranges which can access the kubernetes cluster
  #   Jenkins use case
  #   master_authorized_networks_config {
  #     cidr_blocks {
  #       cidr_block   = "10.0.0.0/18"
  #       display_name = "private-subnet-w-jenkins"
  #     }
  #   }




}