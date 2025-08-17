FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install basic development tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    nano \
    vim \
    jq \
    unzip \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | sh

# Setup user
USER vscode

# Copy shell configuration
COPY .bashrc /home/vscode/.bashrc-devcontainer

# Ensure .bashrc sources our configuration
RUN echo "source /home/vscode/.bashrc-devcontainer" >> /home/vscode/.bashrc

WORKDIR /workspace