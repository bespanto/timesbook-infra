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

resource "docker_image" "timesbook-back" {
  name         = "localhost:5000/timesbook-back"
  keep_locally = false
}

resource "docker_container" "timesbook-back" {
  image    = docker_image.timesbook-back.latest
  name     = "timesbook-back"
  hostname = "timesbook-back"
  networks_advanced {
    name         = "timesbook-net"
    ipv4_address = "172.18.0.31"
  }
  host {
    host = "timesbook-back"
    ip   = "172.18.0.31"
  }
}

resource "docker_image" "timesbook-front" {
  name         = "localhost:5000/timesbook-front"
  keep_locally = false
}

resource "docker_container" "timesbook-front" {
  image    = docker_image.timesbook-front.latest
  name     = "timesbook-front"
  hostname = "timesbook-front"
  networks_advanced {
    name         = "timesbook-net"
    ipv4_address = "172.18.0.30"
  }
  # add timesbook-back host to /etc/hosts
  host {
    host = "timesbook-back"
    ip   = "172.18.0.31"
  }
  # publish port to the world
  ports {
    internal = 80
    external = 80
  }
}

