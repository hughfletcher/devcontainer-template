FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install basic development tools and Node.js
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

# Install Node.js (required for claude-monitor)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | sh

# Install Claude Monitor
RUN npm install -g @anthropic-ai/claude-monitor

# Install MCP Servers
RUN npm install -g @upstash/context7

# Setup user
USER vscode

# Copy shell configuration
COPY .bashrc /home/vscode/.bashrc-devcontainer

# Ensure .bashrc sources our configuration
RUN echo "source /home/vscode/.bashrc-devcontainer" >> /home/vscode/.bashrc

WORKDIR /workspace