THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)


apply: ## applies this
	pushd terraform
	terraform apply -auto-approve
	popd

init: ## first time
	pushd terraform
	terraform init
	popd

destroy:
	pushd terraform
	terraform destroy -auto-approve
	popd

## create public/private keypair for ssh
create-keypair:
	@echo "THISDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

metadata:
	pushd terraform
	terraform refresh && terraform output ips
	popd

iso:
	pushd packer
	packer build centos8.json
	cp -f artifacts/qemu/packer-template-centos8-x86_64 ~/VirtualMachines/centos8-terraform.qcow2
	popd

## list make targets
## https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
