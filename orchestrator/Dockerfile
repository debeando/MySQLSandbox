###############################################################################
# Dockerfile to build Orchestrator container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="GitHub Orchestrator on Centos 7" \
      version="3.0.14"

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

# Install additional repository and add repository key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

###############################################################################
# BEGIN INSTALLATION
###############################################################################
# -----------------------------------------------------------------------------
# Install the Percona repository package
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install https://repo.percona.com/percona/yum/percona-release-1.0-7.noarch.rpm
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona

# -----------------------------------------------------------------------------
# Install MySQL Client
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install Percona-Server-client-57

# -----------------------------------------------------------------------------
# Install Orchestrator
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install wget unzip

RUN yum install epel-release -y && \
    yum install jq -y

RUN yum -y --setopt=tsflags=nodocs --skip-broken install https://github.com/github/orchestrator/releases/download/v3.0.14/orchestrator-3.0.14-1.x86_64.rpm
RUN yum -y --setopt=tsflags=nodocs --skip-broken install https://github.com/github/orchestrator/releases/download/v3.0.14/orchestrator-cli-3.0.14-1.x86_64.rpm

COPY orchestrator.conf.json /etc/orchestrator.conf.json
RUN chown root:root /etc/orchestrator.conf.json && \
    chmod a+x /etc/orchestrator.conf.json

# -----------------------------------------------------------------------------
# Install consul
# -----------------------------------------------------------------------------

ADD https://releases.hashicorp.com/consul/1.4.2/consul_1.4.2_linux_amd64.zip /root/
RUN unzip /root/consul_1.4.2_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.4.2_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY config.json /etc/consul.d/config.json

# -----------------------------------------------------------------------------
# Copy script utility
# -----------------------------------------------------------------------------
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*
############################## INSTALLATION END ###############################

# Set the working directory to /var/www
WORKDIR /root

# Expose the default http port
EXPOSE 3000/tcp

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
