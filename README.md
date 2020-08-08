# Packer Terraform KVM Example

This repo is an example of packer+terraform combo to create a centos8 VM from plain iso.

to start:

`mkdir ~/VirtualMachines`

to create the folder where we put our examples.

To start creating the first VM:

`make iso`

will use packer to create the base image for the VM using `centos8-kickstart.cfg` as ks file.

`make init; make apply` 

will proceede to use terraform to create the machine based on the packer output.


`make destroy`

to remove all
