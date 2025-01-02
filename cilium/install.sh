#!/bin/bash
# Fetch the latest stable version of Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
# Determine the architecture
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then
    CLI_ARCH=arm64
fi
# Download the Cilium CLI tarball and its checksum
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# Verify the checksum
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# Install Cilium CLI
sudo tar xzvf cilium-linux-${CLI_ARCH}.tar.gz -C /usr/local/bin
# Clean up
rm cilium-linux-${CLI_ARCH}.tar.gz cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# Verify installation
cilium version