resource "google_compute_network" "k8s-vnet-tf" {
  name = "k8s-vnet-tf"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "subnet-10-1" {
  name = "subnet-tf-10-1"
  ip_cidr_range = "10.1.0.0/16"
  region = var.gcp_region
  network = google_compute_network.k8s-vnet-tf.id
  secondary_ip_range = [ {
    ip_cidr_range = var.pod_cidr
    range_name = "podips"
  },
  {
    ip_cidr_range = var.service_cidr
    range_name = "serviceips"
  } ]
}



resource "google_compute_firewall" "k8s-vnet-fw-external" {
    name = "k8s-vnet-fw-external"
    network = google_compute_network.k8s-vnet-tf.id
    allow {
      protocol = "tcp"
      ports = ["22","80","443", "30000-40000"]
    }

    allow {
      protocol = "icmp"
    }

    source_ranges = [ "0.0.0.0/0" ] 
}



resource "google_compute_firewall" "k8s-vnet-fw-internal" {
    name = "k8s-vnet-fw-internal"
    network = google_compute_network.k8s-vnet-tf.id
    allow {
      protocol = "tcp"
    }
    allow {
      protocol = "udp"
    }
    allow {
      protocol = "icmp"
    }
    allow {
      protocol = "ipip"
    }
    source_tags = [ "k8s" ] 
}
