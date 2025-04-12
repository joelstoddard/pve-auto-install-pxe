FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cpio \
    file \
    zstd \
    gzip \
    wget \
    git \
    genisoimage \
    gnupg \
    apt-transport-https \
    xorriso && \
    rm -rf /var/lib/apt/lists/*

# Add Proxmox repository and install proxmox-auto-install-assistant
RUN echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve.list && \
    wget -qO- http://download.proxmox.com/debian/proxmox-release-bookworm.gpg | \
    gpg --dearmor > /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    apt-get update && \
    apt-get install -y --no-install-recommends proxmox-auto-install-assistant && \
    rm -rf /var/lib/apt/lists/*

# Fetch the PXE generation script
RUN mkdir -p /tmp/pve-iso-2-pxe && \
    GIT_SSL_NO_VERIFY=true git clone https://github.com/joelstoddard/pve-auto-install-pxe.git /tmp/pve-auto-install-pxe && \
    chmod +x /tmp/pve-auto-install-pxe/pve-iso-2-pxe.sh

# Create directories for volume mounts
RUN mkdir -p /tmp/input /tmp/output

# Create a wrapper script that performs the operations
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]