FROM viceo/devcontainer-base:latest

# Compile Latest Python Version
USER dev
WORKDIR /home/dev
RUN sudo dnf update -y
RUN sudo dnf install gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make tar -y
RUN sudo wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
RUN sudo tar -xf Python-3.12.0.tgz
WORKDIR /home/dev/Python-3.12.0
RUN sudo ./configure --enable-optimizations
RUN sudo make -j $(sudo nproc)
RUN sudo make altinstall

# Compile Cleanup
USER root
WORKDIR /home/dev
RUN rm -f Python-3.12.0.tgz
RUN rm -rf Python-3.12.0

# Create venv and install Ansible
USER dev
WORKDIR /home/dev
RUN python3.12 -m venv venv
RUN venv/bin/pip install ansible
RUN venv/bin/pip install ansible-lint

# Update PATH
ENV PATH="$PATH:/home/dev/venv/bin"

# Start Bash Session
WORKDIR /home/dev
ENTRYPOINT [ "/bin/bash", "-c", "source venv/bin/activate && exec bash" ]
