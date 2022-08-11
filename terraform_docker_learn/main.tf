terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.20.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
  count   = 1
  length  = 4
  special = false
  upper   = false
}



resource "docker_container" "nodered_container" {
  count = 1
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = 1880
    # external = 1880
  }
}

output "ip-address" {
  value       = [for i in docker_container.nodered_container[*]: join(":", [i.ip_address],i.ports[*]["external"])]
  description = "IP address of container"
}

output "container-name" {
  value       = docker_container.nodered_container[*].name
  description = "Name of the container"
}

# output "IP-Address2" {
#   value       = join(":", [docker_container.nodered_container[1].ip_address, docker_container.nodered_container[1].ports[0].external])
#   description = "IP address of container"
# }
