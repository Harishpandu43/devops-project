FROM jenkins/inbound-agent:latest-jdk11

USER root

# Install basic packages and AWS CLI
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    python3-minimal \
    git \
    unzip \
    sudo \
    apt-transport-https && \
    rm -rf /var/lib/apt/lists/* && \
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Podman
RUN apt-get update && \
    apt-get install -y debian-keyring && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_12/Release.key | gpg --dearmor | tee /etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_12/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null && \
    apt-get update -qq && \
    apt-get -y install podman && \
    rm -rf /var/lib/apt/lists/*

# Configure Podman storage
RUN mkdir -p /etc/containers && \
    echo '[storage]' > /etc/containers/storage.conf && \
    echo 'driver = "vfs"' >> /etc/containers/storage.conf && \
    echo 'graphroot = "/var/lib/containers/storage"' >> /etc/containers/storage.conf && \
    echo 'runroot = "/run/containers/storage"' >> /etc/containers/storage.conf

# Configure registries
RUN mkdir -p /etc/containers && \
    echo 'unqualified-search-registries = ["docker.io"]' > /etc/containers/registries.conf && \
    echo 'short-name-mode = "permissive"' >> /etc/containers/registries.conf

# Setup directories and permissions
RUN mkdir -p /var/lib/containers/storage && \
    mkdir -p /run/containers/storage && \
    mkdir -p /home/jenkins/.local/share/containers && \
    mkdir -p /home/jenkins/.jenkins /home/jenkins/.aws && \
    chown -R jenkins:jenkins /home/jenkins && \
    chmod -R 777 /home/jenkins && \
    chown -R jenkins:jenkins /var/lib/containers && \
    chmod -R 777 /var/lib/containers && \
    chown -R jenkins:jenkins /run/containers && \
    chmod -R 777 /run/containers && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
WORKDIR /home/jenkins

# Create .config directory for containers
RUN mkdir -p ~/.config/containers && \
    echo 'storage.driver = "vfs"' > ~/.config/containers/storage.conf && \
    echo 'unqualified-search-registries = ["docker.io"]' > ~/.config/containers/registries.conf

# Verify installations
RUN kubectl version --client && \
    helm version && \
    aws --version && \
    sudo podman --version

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
