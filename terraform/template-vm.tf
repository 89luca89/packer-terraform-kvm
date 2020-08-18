# variables that can be overriden
#
#

# to set hostname and source file use:
#   -var 'hostname=example' -var 'source=~/VirtualMachines/example.qcow2'
variable "cpu" { default = 2 }
variable "disk_source" { default = "" }
variable "domain" { default = "" }
variable "hostname" { default = "" }
variable "macvtap_iface" { default = "" }
variable "memory_mb" { default = 1024 * 4 }
variable "provider_uri" { default = "qemu:///system" }
variable "pool_name" { default = "" }

# instance the provider
provider "libvirt" {
  uri = var.provider_uri
}

# Base OS image to use to create a cluster of different
# nodes
resource "libvirt_volume" "os_image" {
  name   = format("%s-%s", var.hostname, "terraform")
  source = pathexpand(var.disk_source)
  pool   = var.pool_name
  format = "qcow2"
}

# Create the machine
resource "libvirt_domain" "domain-terraform" {
  name   = var.hostname
  memory = var.memory_mb
  vcpu   = var.cpu

  cpu = {
    mode = "host-passthrough"
  }

  disk { volume_id = libvirt_volume.os_image.id }
  boot_device { dev = ["cdrom", "hd", "network"] }

  # filesystem {
  #   source   = pathexpand("~/")
  #   target   = "mnt"
  #   readonly = false
  # }

  # uses static  IP
  network_interface {
    network_name   = "default"
    hostname       = var.hostname
    addresses      = ["192.168.122.241"]
    mac            = "AA:BB:CC:11:24:23"
    wait_for_lease = true
  }

  #  network_interface {
  #    bridge  = var.macvtap_iface
  #    hostname = var.hostname
  #  }

  # IMPORTANT
  # it will show no console otherwise
  video {
    type = "qxl"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  connection {
    type             = "ssh"
    host             = self.network_interface[0].addresses[0]
    user             = "root"
    password         = "root"
    bastion_host     = "10.90.20.21"
    bastion_port     = "22"
    bastion_user     = "root"
    bastion_password = "password"
  }

  # Hostdev passtrought
  # provisioner "local-exec" {
  #   command = "virsh --connect ${var.provider_uri} attach-device ${var.hostname} --file passtrought-host.xml --live --persistent"
  # }

  # provisioner "remote-exec" {
  #   inline = ["echo first", "echo first second"]
  # }

  # provisioner "remote-exec" {
  #   inline = ["nmcli con mod \"$(nmcli -t -f NAME c s  | grep -v eth0)\" ipv4.addresses 10.0.0.60/24 ipv4.dns 10.0.0.1"]
  # }
}

terraform {
  required_version = ">= 0.12"
}

output "metadata" {
  # run 'terraform refresh' if not populated
  value = libvirt_domain.domain-terraform
}
