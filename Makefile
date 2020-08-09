THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)
distro ?= CFG_DISTRO_ID

apply: ## applies this
	cd terraform &&	terraform apply -auto-approve -var 'hostname=$(distro)' -var 'disk_source=~/VirtualMachines/$(distro)-terraform.qcow2'

init: ## first time
	cd terraform &&	terraform init -var 'hostname=$(distro)' -var 'disk_source=~/VirtualMachines/$(distro)-terraform.qcow2'

destroy:
	cd terraform &&	terraform destroy -auto-approve -var 'hostname=$(distro)' -var 'disk_source=~/VirtualMachines/$(distro)-terraform.qcow2'

## create public/private keypair for ssh
create-keypair:
	@echo "THISDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

iso:
	cd packer/$(distro) && packer build $(distro).json
	cp -f packer/$(distro)/artifacts/qemu/packer-template-$(distro)-x86_64 ~/VirtualMachines/$(distro)-terraform.qcow2
	rm -rf packer/$(distro)/artifacts/qemu

## list make targets
## https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
