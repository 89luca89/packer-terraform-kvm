# variables that can be overriden
#
#

# to set hostname and source file use:
#   -var 'hostname=example' -var 'source=~/VirtualMachines/example.qcow2'
variable "hostname" { default = "base-hostname" }
variable "disk_source" { default = "~/VirtualMachines/image-terraform.qcow2" }
variable "domain" { default = "lan" }
variable "memory_mb" { default = 1024 * 4 }
variable "cpu" { default = 2 }
variable "macvtap_iface" { default = "enp0s31f6" }

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# Base OS image to use to create a cluster of different
# nodes
resource "libvirt_volume" "os_image" {
  name   = "packer-template"
  source = pathexpand(var.disk_source)
  pool   = "pool"
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

  filesystem {
    source   = pathexpand("~/")
    target   = "mnt"
    readonly = false
  }

  # uses static  IP
  network_interface {
    network_name   = "default"
    hostname       = var.hostname
    addresses      = ["192.168.124.203"]
    mac            = "AA:BB:CC:11:22:22"
    wait_for_lease = true
  }

 #  network_interface {
 #    macvtap  = var.macvtap_iface
 #    hostname = var.hostname
 #  }

  # IMPORTANT
  # it will show no console otherwise
  video {
    type = "qxl"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
    autoport    = "true"
  }

  connection {
    type     = "ssh"
    host     = self.network_interface[0].addresses[0]
    user     = "root"
    password = "root"
  }

  # Hostdev passtrought
  # provisioner "local-exec" {
  #   command = "virsh --connect qemu:///system  attach-device ${var.hostname} --file passtrought-host.xml --live --persistent"
  # }

  # provisioner "remote-exec" {
  #   inline = ["echo first", "echo first second"]
  # }

  # provisioner "remote-exec" {
  #   inline = ["echo second"]
  # }
}

terraform {
  required_version = ">= 0.12"
}

output "metadata" {
  # run 'terraform refresh' if not populated
  value = libvirt_domain.domain-terraform
}
