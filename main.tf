terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

provider "docker" {

   registry_auth {
      address = "registry.gitlab.com"
      config_file = "${pathexpand("~/.docker/config.json")}"
    }
}

resource "docker_network" "private_network" {
  name = "timesbook-net"
  ipam_config {
    subnet  = "172.18.0.0/16"
    gateway = "172.18.0.1"
  }
}

resource "docker_image" "timesbook-back" {
  name         = "registry.gitlab.com/sstyle/timesbook-backend"
  keep_locally = true
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
  volumes {
    container_path  = "/usr/src/app"
    read_only = false
    host_path = "/home/sstyle/timesbook-backend"
  }
}

resource "docker_image" "timesbook-front" {
  name         = "registry.gitlab.com/sstyle/timesbook-frontend"
  keep_locally = true
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

