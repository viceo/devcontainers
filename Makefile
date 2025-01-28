.PHONY: help
help:
	@echo "[options]"
	@echo "\tmake all"
	@echo "\tmake base"
	@echo "\tmake ansible "

.PHONY: all
all: base ansible

.PHONY: base
base:
	@echo "Building Docker image for Base..."
	docker build -t viceo/devcontainer-base:latest -f ./Containerfiles/.base.containerfile .
	@echo "Pushing Docker image to Docker Hub..."
	docker push viceo/devcontainer-base:latest

.PHONY: ansible
ansible:
	@echo "Building Docker image for Ansible..."
	docker build -t viceo/devcontainer-ansible:latest -f ./Containerfiles/ansible.containerfile .
	@echo "Pushing Docker image to Docker Hub..."
	docker push viceo/devcontainer-ansible:latest

