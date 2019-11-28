provider "google" {
  credentials = file("./credentials.json")
  project     = var.gcp_project
  region      = var.gcp_region
}

provider "rancher2" {
  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

data "google_compute_zones" "available" {}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "random_id" "worker_instance_id" {
  count       = var.nodes
  byte_length = 8
}

resource "google_compute_firewall" "firewall" {
  name    = "rke-node-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  # These IP ranges are required for health checks
  source_ranges = ["0.0.0.0/0"]

  # Target tags define the instances to which the rule applies
  target_tags = ["rke"]
}

resource "google_compute_instance" "rke" {
  count        = var.nodes
  name         = "rke-gcp-${random_id.worker_instance_id[count.index].hex}"
  machine_type = var.machine_type
  zone         = data.google_compute_zones.available.names[count.index]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  tags = ["rke"]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = self.network_interface.0.access_config.0.nat_ip
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`"
    ]
  }
}