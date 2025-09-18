FROM ghcr.io/envwizard/python310-base:latest@sha256:df62016190ed8b9655a9da4cc253e729f2117cffe9fef5cba8c1dfd0ff74149a

# Environment variables

# Switch to root to install system dependencies
USER root

WORKDIR /workspace

# Install system dependencies for Python development
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Clone repository
RUN git clone https://github.com/Kalebu/Website-blocker-python /workspace/repo

WORKDIR /workspace/repo

# Create script to copy repository content to workspace
RUN echo '#!/bin/bash' > /usr/local/bin/copy-repo.sh && \
    echo 'echo "Copying repository content to workspace..."' >> /usr/local/bin/copy-repo.sh && \
    echo 'if [ -d "/workspace/repo" ] && [ -d "/workspaces" ]; then' >> /usr/local/bin/copy-repo.sh && \
    echo '  # Find the workspace directory' >> /usr/local/bin/copy-repo.sh && \
    echo '  WORKSPACE_DIR=$(find /workspaces -maxdepth 1 -type d ! -path /workspaces | head -1)' >> /usr/local/bin/copy-repo.sh && \
    echo '  if [ -n "$WORKSPACE_DIR" ] && [ -d "$WORKSPACE_DIR" ]; then' >> /usr/local/bin/copy-repo.sh && \
    echo '    echo "Found workspace directory: $WORKSPACE_DIR"' >> /usr/local/bin/copy-repo.sh && \
    echo '    # Copy repository files to workspace directory' >> /usr/local/bin/copy-repo.sh && \
    echo '    cp -r /workspace/repo/. "$WORKSPACE_DIR/" 2>/dev/null || true' >> /usr/local/bin/copy-repo.sh && \
    echo '    echo "Repository files copied to workspace"' >> /usr/local/bin/copy-repo.sh && \
    echo '  else' >> /usr/local/bin/copy-repo.sh && \
    echo '    echo "No workspace directory found"' >> /usr/local/bin/copy-repo.sh && \
    echo '  fi' >> /usr/local/bin/copy-repo.sh && \
    echo 'else' >> /usr/local/bin/copy-repo.sh && \
    echo '  echo "Source or target directory not found"' >> /usr/local/bin/copy-repo.sh && \
    echo 'fi' >> /usr/local/bin/copy-repo.sh && \
    chmod +x /usr/local/bin/copy-repo.sh

# Setup script
RUN echo '#!/bin/bash' > /tmp/setup.sh && \
    echo 'set -e' >> /tmp/setup.sh && \
    echo "ls -l" >> /tmp/setup.sh && \
    echo "cat README.md" >> /tmp/setup.sh && \
    echo "head -20 app.py" >> /tmp/setup.sh && \
    echo "head -20 'app v2.py'" >> /tmp/setup.sh && \
    echo "pip install --upgrade pip" >> /tmp/setup.sh && \
    echo "pip install --no-input datetime" >> /tmp/setup.sh && \
    chmod +x /tmp/setup.sh && \
    /tmp/setup.sh

# Switch back to vscode user for development
USER vscode