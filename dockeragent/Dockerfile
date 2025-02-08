FROM jenkins/inbound-agent:latest-jdk17

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
    apt-transport-https \
    fuse-overlayfs \
    uidmap \
    slirp4netns && \
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

# Install Podman and Buildah
RUN apt-get update && \
    apt-get install -y debian-keyring && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_12/Release.key | gpg --dearmor | tee /etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_12/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    podman \
    buildah \
    runc \
    containernetworking-plugins \
    containers-common \
    && rm -rf /var/lib/apt/lists/*

# Configure storage for Podman and Buildah
RUN mkdir -p /etc/containers && \
    echo '[storage]' > /etc/containers/storage.conf && \
    echo 'driver = "overlay"' >> /etc/containers/storage.conf && \
    echo 'graphroot = "/var/lib/containers/storage"' >> /etc/containers/storage.conf && \
    echo 'runroot = "/run/containers/storage"' >> /etc/containers/storage.conf && \
    echo '' >> /etc/containers/storage.conf && \
    echo '[storage.options]' >> /etc/containers/storage.conf && \
    echo 'mount_program = "/usr/bin/fuse-overlayfs"' >> /etc/containers/storage.conf && \
    echo 'mountopt = "nodev,fsync=0"' >> /etc/containers/storage.conf

# Configure container engine settings
RUN echo '[containers]' > /etc/containers/containers.conf && \
    echo 'netns="host"' >> /etc/containers/containers.conf && \
    echo 'userns="host"' >> /etc/containers/containers.conf && \
    echo 'ipcns="host"' >> /etc/containers/containers.conf && \
    echo 'utsns="host"' >> /etc/containers/containers.conf && \
    echo 'cgroupns="host"' >> /etc/containers/containers.conf && \
    echo 'cgroups="disabled"' >> /etc/containers/containers.conf && \
    echo '' >> /etc/containers/containers.conf && \
    echo '[engine]' >> /etc/containers/containers.conf && \
    echo 'events_logger="file"' >> /etc/containers/containers.conf && \
    echo 'cgroup_manager="cgroupfs"' >> /etc/containers/containers.conf && \
    echo 'runtime="runc"' >> /etc/containers/containers.conf

# Configure registries
RUN echo 'unqualified-search-registries = ["docker.io"]' > /etc/containers/registries.conf && \
    echo 'short-name-mode = "permissive"' >> /etc/containers/registries.conf

# Setup directories and permissions
RUN mkdir -p /var/lib/containers/storage && \
    mkdir -p /run/containers/storage && \
    mkdir -p /home/jenkins/.local/share/containers && \
    mkdir -p /home/jenkins/.jenkins /home/jenkins/.aws && \
    mkdir -p /home/jenkins/.config/containers && \
    chown -R jenkins:jenkins /home/jenkins && \
    chmod -R 777 /home/jenkins && \
    chown -R jenkins:jenkins /var/lib/containers && \
    chmod -R 777 /var/lib/containers && \
    chown -R jenkins:jenkins /run/containers && \
    chmod -R 777 /run/containers && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure subuid and subgid
RUN touch /etc/subuid /etc/subgid && \
    usermod --add-subuids 100000-165535 --add-subgids 100000-165535 jenkins

USER jenkins
WORKDIR /home/jenkins

# Configure user-specific container settings
RUN mkdir -p ~/.config/containers && \
    echo '[storage]' > ~/.config/containers/storage.conf && \
    echo 'driver = "overlay"' >> ~/.config/containers/storage.conf && \
    echo 'graphroot = "/var/lib/containers/storage"' >> ~/.config/containers/storage.conf && \
    echo 'runroot = "/run/containers/storage"' >> ~/.config/containers/storage.conf && \
    echo '[storage.options]' >> ~/.config/containers/storage.conf && \
    echo 'mount_program = "/usr/bin/fuse-overlayfs"' >> ~/.config/containers/storage.conf

# Verify installations
RUN kubectl version --client && \
    helm version && \
    aws --version && \
    sudo podman --version && \
    sudo buildah --version

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
