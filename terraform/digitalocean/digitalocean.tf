### Configure variables
variable "do_api_token" {
  type        = "string"
  description = "DigitalOcean API token"
}

variable "root_ssh_keys" {
  type        = "list"
  description = "SSH keys for root user"
  default     = []
}

variable "droplet_image" {
  type        = "string"
  description = "Droplet image"
  default     = "ubuntu-16-04-x64"
}

variable "droplet_size" {
  type        = "map"
  description = "Droplet size"
  default     = {}
}

variable "droplet_hostname" {
  type        = "list"
  description = "Droplet hostnames"
}

variable "droplet_tags" {
  type        = "list"
  description = "Droplet tags"
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_api_token}"
}

### Create tags ###

# Create production/testing tags
resource "digitalocean_tag" "production" {
  name = "production"
}

resource "digitalocean_tag" "testing" {
  name = "testing"
}

# Create blue/green tags
resource "digitalocean_tag" "blue" {
  name = "blue"
}

resource "digitalocean_tag" "green" {
  name = "green"
}

# Create role-based tags

resource "digitalocean_tag" "docker" {
  name = "docker"
}

### Create Firewalls ###

resource "digitalocean_firewall" "production" {
  name = "production-firewall"
  tags = ["production"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

### Create Droplets ###

# Create servers
resource "digitalocean_droplet" "servers" {
  image              = "${var.droplet_image}"
  name               = "${var.droplet_hostname[count.index]}"
  tags               = "${var.droplet_tags[count.index]}"
  region             = "sfo2"
  size               = "${lookup(var.droplet_size, count.index, "s-1vcpu-1gb")}"
  monitoring         = true
  ipv6               = true
  private_networking = true
  backups            = true
  ssh_keys           = "${var.root_ssh_keys}"

  count = "${length(var.droplet_hostname)}"

  lifecycle = {
    ignore_changes = ["image"]
  }
}
