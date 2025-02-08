FROM jenkins/inbound-agent:latest-jdk17

USER root

# Install basic packages and tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    python3-minimal \
    git \
    unzip \
    sudo \
    apt-transport-https \
    uidmap \
    slirp4netns && \
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip && \
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Podman
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_12/Release.key | \
    gpg --dearmor | tee /etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_12/ /" | \
    tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    podman \
    containernetworking-plugins \
    containers-common && \
    rm -rf /var/lib/apt/lists/*

# Configure container runtime
RUN mkdir -p /etc/containers && \
    tee /etc/containers/containers.conf <<EOF
[containers]
netns="host"
userns="host"
ipcns="host"
utsns="host"
cgroupns="host"
cgroups="disabled"

[engine]
events_logger="file"
cgroup_manager="cgroupfs"
EOF

# Configure storage to use VFS
RUN tee /etc/containers/storage.conf <<EOF
[storage]
driver = "vfs"
runroot = "/run/containers/storage"
graphroot = "/var/lib/containers/storage"
EOF

# Setup permissions and directories
RUN mkdir -p /var/lib/containers/storage \
    /run/containers/storage \
    /home/jenkins/.local/share/containers \
    /home/jenkins/.jenkins \
    /home/jenkins/.aws \
    /home/jenkins/.config/containers && \
    chown -R jenkins:jenkins /home/jenkins /var/lib/containers /run/containers && \
    chmod -R 777 /home/jenkins /var/lib/containers /run/containers && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
WORKDIR /home/jenkins

# Verify installations
RUN kubectl version --client && \
    helm version && \
    aws --version && \
    sudo podman --version

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]