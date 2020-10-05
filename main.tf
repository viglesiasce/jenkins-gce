# TODO
# - add cloud NAT
# - add IAM roles to Jenkins service account

variable "zone" {
  default = "us-central1-f"
}

provider google {
  project = "INSERT_YOUR_PROJECT_ID"
}

resource "google_service_account" "jenkins" {
  account_id   = "jenkins"
  display_name = "Jenkins Service Account"
}

resource "google_compute_disk" "jenkins-home" {
  name = "jenkins-home"
  type = "pd-ssd"
  zone = "${var.zone}"
  size = 200
}

resource "google_compute_instance" "default" {
  name         = "jenkins"
  machine_type = "n2-standard-8"
  zone         = "${var.zone}"

  tags = ["jenkins", "ci"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
  metadata = {
    user-data = file("cloud-init.yaml")
  }

  attached_disk {
    device_name = "jenkins-home"
    source = "${google_compute_disk.jenkins-home.self_link}"
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = "${google_service_account.jenkins.email}"
  }
}