FROM almalinux:9.5

ARG USER_UID=1000
ARG USER_GID=1000

# Create passwordless sudoer user viceo
RUN groupadd -g ${USER_GID} viceo
RUN useradd -l -u ${USER_UID} -g viceo viceo
RUN install -d -m 0755 -o viceo -g viceo /home/viceo
RUN usermod -aG wheel viceo
RUN mkdir /etc/sudoers.d && echo "viceo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/viceo
RUN chmod 440 /etc/sudoers.d/viceo
RUN dnf install -y sudo

# Compile Latest Python Version
USER viceo
WORKDIR /home/viceo
RUN sudo dnf update -y
RUN sudo dnf install gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make tar -y
RUN sudo wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
RUN sudo tar -xf Python-3.12.0.tgz
WORKDIR /home/viceo/Python-3.12.0
RUN sudo ./configure --enable-optimizations
RUN sudo make -j $(sudo nproc)
RUN sudo make altinstall

# Compile Cleanup
USER root
WORKDIR /home/viceo
RUN rm -f Python-3.12.0.tgz
RUN rm -rf Python-3.12.0

# Install distro packages
USER root
RUN dnf install -y which
RUN dnf install git -y
RUN dnf install ncurses -y
RUN dnf install openssh-clients -y

# Define useful aliases
USER viceo
WORKDIR /home/viceo
RUN mkdir .bashrc.d
RUN cat <<EOL > .bashrc.d/aliases
alias ll='ls -l'
alias la='ls -la'
EOL

# Create venv and install Ansible
USER viceo
WORKDIR /home/viceo
RUN python3.12 -m venv venv
RUN venv/bin/pip install ansible
RUN venv/bin/pip install ansible-lint

# Update PATH
ENV PATH="$PATH:/home/viceo/venv/bin"

# Start Bash Session
WORKDIR /home/viceo
ENTRYPOINT [ "/bin/bash", "-c", "source venv/bin/activate && exec bash" ]
