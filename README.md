# Packer Terraform KVM Example

This repo is an example of packer+terraform combo to create a centos8 VM from plain iso.

This is based on Libvirt/KVM for virtualization, so it depends on the terraform provider for libvirt:

[terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/)

Prerequisites:

- packer
- terraform
- terraform-provider-libvirt
- make

to start:

`mkdir ~/VirtualMachines`

to create the folder where we put our examples.

To start creating the first VM:

`make iso`

will use packer to create the base image for the VM using `centos8-kickstart.cfg` as ks file.
This will search for an install iso in the current directory, this example uses `CentOS-8.1.1911-x86_64-dvd1.iso`,
change the value/path as needed for the test

`make init; make apply` 

will proceede to use terraform to create the machine based on the packer output.


`make destroy`

to remove all
