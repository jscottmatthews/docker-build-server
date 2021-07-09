#variables

variable "region" {
    default = "us-central1"
}

variable "zone" {
    default = "us-central1-a"
}

variable "project_name" {
    description = "Project ID"
}

variable "docker_declaration" {
  type = string
  default = "spec:\n  containers:\n    - name: test-docker\n      image: 'jenkins/jenkins:lts-jdk11'\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
}


#provider

provider "google" {
    credentials = file("key.json")
    project = var.project_name
    region = var.region
}


#infra

resource "google_compute_instance" "default" {
    name            = "server"
    zone            = "us-central1-a"
    machine_type    = "e2-medium"
    tags =[
        "name","default"
    ]

    boot_disk {
      initialize_params {
          image = "projects/cos-cloud/global/images/cos-77-12371-1109-0"
          type  = "pd-balanced"
      }
    }

    metadata = {
      gce-container-declaration = var.docker_declaration
    }

    labels = {
        container-vm = "cos-77-12371-1109-0"
    }

    network_interface {
      network = "default"
      access_config {
      }
    }

}

resource "google_compute_firewall" "http-8080" {
    name        = "port-8080"
    network     = "default"

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports    = ["8080","50000"]
    }    

    source_ranges = ["0.0.0.0/0"]
    source_tags   = ["default"] 
}


# outputs

output "IP_Address" {
    value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

/* docker run -d -p 8080:8080 jenkins/jenkins:lts-jdk11
docker container ls 
docker exec -it CONTAINER_ID /bin/bash
cat /var/jenkins_home/secrets/initialAdminPassword
*/