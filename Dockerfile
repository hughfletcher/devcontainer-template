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
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for MCP servers)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Context7 MCP Server (npm package) globally as root
RUN npm install -g @upstash/context7-mcp

# Setup user
USER vscode

# Ensure pipx and local bin are in PATH for vscode user
ENV PATH="/home/vscode/.local/bin:$PATH"

# Install Claude Monitor (Python package) as vscode user
RUN pipx install claude-monitor

# Note: Claude Code CLI will be installed in setup.sh to avoid architecture issues during build

# Copy shell configuration
COPY .bashrc /home/vscode/.bashrc-devcontainer

# Ensure .bashrc sources our configuration
RUN echo "source /home/vscode/.bashrc-devcontainer" >> /home/vscode/.bashrc

# Fix permissions and pre-create vscode-server directory structure
USER root
RUN chown -R vscode:vscode /home/vscode \
    && mkdir -p /home/vscode/.vscode-server/bin /home/vscode/.vscode-server/data/Machine \
    && chown -R vscode:vscode /home/vscode/.vscode-server

# Switch back to vscode user
USER vscode

# Note: WORKDIR will be set by devcontainer.json workspaceFolder setting