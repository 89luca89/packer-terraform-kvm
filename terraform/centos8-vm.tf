# variables that can be overriden
variable "hostname" { default = "centos-terraform" }
variable "domain" { default = "lan" }
variable "memory_mb" { default = 1024 * 4 }
variable "cpu" { default = 2 }
variable "macvtap_iface" { default = "eth0" }

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# Base OS image to use to create a cluster of different
# nodes
resource "libvirt_volume" "os_image" {
  name   = "packer-template-centos8"
  source = pathexpand("~/VirtualMachines/centos8-terraform.qcow2")
  pool   = "pool"
  format = "qcow2"
}

# Create the machine
resource "libvirt_domain" "domain-centos" {
  name   = var.hostname
  memory = var.memory_mb
  vcpu   = var.cpu

  cpu = {
    mode = "host-passthrough"
  }

  disk { volume_id = libvirt_volume.os_image.id }
  boot_device { dev = ["cdrom", "hd", "network"] }

  # uses static  IP
  network_interface {
    network_name   = "default"
    hostname       = var.hostname
    addresses      = ["192.168.124.203"]
    mac            = "AA:BB:CC:11:22:22"
    wait_for_lease = true
  }

  network_interface {
    macvtap  = var.macvtap_iface
    hostname = var.hostname
  }

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
  value = libvirt_domain.domain-centos
}
