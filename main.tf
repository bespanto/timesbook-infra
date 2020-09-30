terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

provider "docker" {

  # registry_auth {
  #    address = "localhost:5000"
  #    config_file = "${pathexpand("~/.docker/config.json")}"
  #  }
}


resource "docker_network" "private_network" {
  name = "timesbook-net"
  ipam_config {
    subnet  = "172.18.0.0/16"
    gateway = "172.18.0.1"
  }
}

resource "docker_image" "timesbook" {
  name = "localhost:5000/timesbook-front"
  # keep_locally = false
}

resource "docker_container" "timesbook" {
  image = docker_image.timesbook.latest
  name  = "timesbook-app"
  # hostname = "timesbook-front"
  networks_advanced {
    name         = "timesbook-net"
    ipv4_address = "172.18.0.30"
  }
  host {
    host = "timesbook-front"
    ip   = "172.18.0.30"
  }
  ports {
    internal = 80
    external = 80
  }
}

