#!/bin/bash
set -eo pipefail

# Check for required files
if [ -f "/tmp/input/answers.toml" ] && [ -f "/tmp/input/proxmox.iso" ]; then
    echo "Found answers.toml and ISO. Processing..."
    
    # Generate custom ISO with proxmox-auto-install-assistant
    echo "Generating custom auto install Proxmox ISO with options from provided answers.toml..."
    proxmox-auto-install-assistant prepare-iso \
        /tmp/input/proxmox.iso \
        --fetch-from iso \
        --answer-file /tmp/input/answers.toml \
        --output /tmp/pve-auto-install-pxe.iso
    
    # Verify ISO was created
    if [ -f "/tmp/pve-auto-install-pxe.iso" ]; then
        echo "Successfully generated headless Proxmox ISO"
        
        # Convert to PXE format
        echo "Converting ISO to PXE format..."
        /tmp/pve-auto-install-pxe/pve-iso-2-pxe.sh /tmp/pve-auto-install-pxe.iso
        
        # Copy PXE files to output directory
        if [ -d "/tmp/output" ]; then
            echo "Copying PXE files & ISO to output directory..."
            cp -r /tmp/pxeboot/* /tmp/pve-auto-install-pxe.iso /tmp/output/
            echo "PXE files copied to output directory"
        fi
    else
        echo "Error: Failed to generate custom Proxmox ISO"
    fi
else
    echo "Missing required input files:"
    [ ! -f "/tmp/input/answers.toml" ] && echo " - answers.toml not found in /tmp/input/"
    [ ! -f "/tmp/input/proxmox.iso" ] && echo " - An iso file not found in /tmp/input/"
fi