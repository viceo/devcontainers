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
RUN dnf install util-linux-user -y
RUN dnf install zsh -y
RUN dnf install wget -y
RUN dnf groupinstall 'Development Tools' -y

# ZSH Setup
USER dev
ENV HOME=/home/dev
RUN sudo chsh -s /usr/bin/zsh $(whoami)
RUN curl -fsSL https://raw.githubusercontent.com/viceo/ohmyzsh/refs/heads/master/tools/install.sh | sh
ENV ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
RUN cat <<EOF > "$ZSH_CUSTOM/aliases.zsh"
alias ll='ls -lh'
alias la='ls -la'
EOF
RUN mkdir -p "$ZSH_CUSTOM/themes"
RUN wget -q -O "$ZSH_CUSTOM/themes/hyperzsh.zsh-theme" https://raw.githubusercontent.com/viceo/hyperzsh/master/hyperzsh.zsh-theme
RUN sed -i 's/^ZSH_THEME="[^"]*"/ZSH_THEME="hyperzsh"/' "$HOME/.zshrc"

# EZA Setup
USER dev
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN . "$HOME/.cargo/env" && cargo install eza

# Define aliases
RUN cat <<EOL > "$HOME/.oh-my-zsh/custom/aliases.zsh"
alias ls='eza -g'
alias ll='ls -l'
alias la='ls -la'
EOL
