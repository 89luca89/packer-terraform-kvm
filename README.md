# Packer Terraform KVM Example

This repo is an example of packer+terraform combo to create a VM from plain iso.

Supported os for now are:

- centos 8
- opensuse leap 15.2

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

`make iso distro=centos8`

or

`make iso distro=opensuse15.2`

will use packer to create the base image for the VM using `centos8-kickstart.cfg` as ks file or `autoyast.xml` for opensuse.
This will search for an install iso in the current directory, this example uses `CentOS-8.1.1911-x86_64-dvd1.iso` for centos and
`openSUSE-Leap-15.2-DVD-x86_64.iso` for opensuse, 

change the value/path as needed for the test

`make init; make apply` 

will proceede to use terraform to create the machine based on the packer output.


`make destroy`

to remove all
