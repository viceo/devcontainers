.PHONY: ansible
ansible:
	@echo "Building Docker image for Ansible..."
	docker build -t viceo/devcontainer-ansible:latest -f ./Containerfiles/devcontainer-ansible .
	@echo "Pushing Docker image to Docker Hub..."
	docker push viceo/devcontainer-ansible:latest

