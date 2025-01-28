FROM almalinux:9.5

ARG USER_UID=1000
ARG USER_GID=1000

# Create passwordless sudoer user dev
RUN groupadd -g ${USER_GID} dev
RUN useradd -l -u ${USER_UID} -g dev dev
RUN install -d -m 0755 -o dev -g dev /home/dev
RUN usermod -aG wheel dev
RUN mkdir /etc/sudoers.d && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev
RUN chmod 440 /etc/sudoers.d/dev
RUN dnf install -y sudo

# Install distro packages
USER root
RUN dnf install -y which
RUN dnf install git -y
RUN dnf install ncurses -y
RUN dnf install openssh-clients -y

# Define useful aliases
USER dev
WORKDIR /home/dev
RUN mkdir .bashrc.d
RUN cat <<EOL > .bashrc.d/aliases
alias ll='ls -l'
alias la='ls -la'
EOL
