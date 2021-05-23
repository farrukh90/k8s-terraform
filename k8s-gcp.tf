resource "google_compute_instance" "k8s-vms" {
    for_each = local.k8s_vms
    name = join("-",["k8s", each.key])
    machine_type = "n1-standard-2"
    zone = local.gcp_zone

    tags = [ "k8s", join("-",["k8s", each.key]) ]

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-minimal-1804-lts"
            size = 50
        }
  }

  network_interface {
    network = google_compute_network.k8s-vnet-tf.id
    subnetwork = google_compute_subnetwork.subnet-10-1.id
    access_config {
      // Allocate epheneral IP
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = each.key == "master" ? join("\n", 
      [local.base_install_script, local.cluster_and_nw_install_script]
      ) : ( each.key == "gvisor" ? local.gvisor_install_script : local.base_install_script )
}