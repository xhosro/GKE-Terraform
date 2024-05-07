# When you use a GKE, the kubernetes control plane is managed by google. you only need worry about the place of workes nodes
# vpc in google cloud is global concept, in AWS, vpc belongs to a specific region
resource "google_compute_network" "main" {
    name = "main"
    routing_mode = "REGIONAL" # or GLOBAL
    auto_create_subnetworks = false # network will be created in costom mode
    mtu = 1460 # Maximum transmission units in bytes
    delete_default_routes_on_create = false # for blocking connections to the internet

    depends_on = [
        google_project_service.compute,
        google_project_service.container
    ]
}


#subnet network

resource "google_compute_subnetwork" "main" {
    name = "main"
    network = google_compute_network.main.id
    ip_cidr_range = "10.0.0.0/18" # 16000 IPs to play with
    region = "eu-west1"
    private_ip_google_access = true # VMs in this subnetwork without external IP addresses can access google APIs & services forexample maneged redis or postgres

    # kubernetes nodes use IPs from main cidr range & kubernetes pods use IPs from the secondary cidr range
    secondrary_ip_range {
        range_name = "k8s-pod-range"
        ip_cidr_range = "10.24.0.0/14"

    }

    # for CLUSTER IPS in kubernetes like the services
    secondary_ip_range {
        range_name = "k8s-service-range"
        ip_cidr_range = "10.22.0.0/20"

    }
}


#router
# it will be used with the NAT gateway to allow VMs without public IP addresses to access internet, kubernetes nodes to pull docker images from dockerhub
resource "google_computer_router" "router" {
    name = "router"
    region = "eu-west1"
    network = google_compute_network.main.id
}


#NAT
resource "google_compute_router_nat" "nat" {
    name = "nat"
    region = "eu-west1"
    router = google_computer_router.router.id

    nat_ip_allocate_option = "MANUAL_ONLY" # if you have external clients
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS" # advertise NAT to all subnets or specific one, here the private subnet only

    subnetwork {
        name = "google_computer_subnetwork.main.id"
        source_ip_ranges_to_nat = [All_IP_RANGES]
    }

    nat_ips = [google_compute_address.nat.self_link]
}


resource "google_compute_address" "nat" {
    name = "nat"
    region = "eu-west1"
    address_type = "EXTERNAL"
    network_tier = "PREMIUM" # standard

    depends_on = [
        google_project_service.compute]

    subnetwork = google_compute_subnetwork.main.id
}


#firewall

resource "google_compute_firewall" "allow-ssh" {
    name = "allow-ssh"
    network = google_compute_network.main.id
    priority = 1000

    allow {
        protocol = "tcp"
        ports = ["22"]
        source_ranges = ["0.0.0.0/0"]
    }