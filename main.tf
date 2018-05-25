data "google_compute_subnetwork" "job" {
  name = "${var.subnetwork_name}"
}

data "template_file" "startup_script" {
  template = "${file("${path.module}/templates/install.sh")}"

  vars {
    db_internal_ip = "${var.db_internal_ip}"
  }
}

resource "random_pet" "name" {
  length = "1"
  prefix = "job"
}

resource "google_compute_instance" "job" {
  name         = "${random_pet.name.id}"
  machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  allow_stopping_for_update = true

  labels = {
    name = "job"
  }

  tags = ["job"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Local SSD disk
  scratch_disk {}

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.job.self_link}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    sshKeys                = "ubuntu:${file(var.ssh_public_key_filepath)}"
    block-project-ssh-keys = "TRUE"
    startup-script         = "${data.template_file.startup_script.rendered}"
  }
}

resource "google_compute_firewall" "job_tcp22_ingress" {
  name    = "${random_pet.name.id}-tcp22-ingress"
  network = "${data.google_compute_subnetwork.job.network}"

  direction = "INGRESS"

  priority = 999

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.engineer_cidrs}"

  target_tags = ["job"]
}

resource "google_compute_firewall" "job_to_db_tcp28015_ingress" {
  name    = "${random_pet.name.id}-to-db-tcp28015-ingress"
  network = "${data.google_compute_subnetwork.job.network}"

  direction = "INGRESS"

  priority = 998

  allow {
    protocol = "tcp"
    ports    = ["28015"]
  }

  source_tags = ["job"]

  target_tags = ["db"]
}
