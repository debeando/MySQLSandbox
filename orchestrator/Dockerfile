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
      version="2.1.5"

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
RUN yum -y --setopt=tsflags=nodocs install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona

# -----------------------------------------------------------------------------
# Install MySQL Client
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install Percona-Server-client-57

# -----------------------------------------------------------------------------
# Install Orchestrator
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install wget

RUN yum -y --setopt=tsflags=nodocs install https://github.com/github/orchestrator/releases/download/v2.1.5/orchestrator-2.1.5-1.x86_64.rpm
RUN yum -y --setopt=tsflags=nodocs install https://github.com/github/orchestrator/releases/download/v2.1.5/orchestrator-cli-2.1.5-1.x86_64.rpm

COPY orchestrator.conf.json /etc/orchestrator.conf.json
RUN chown root:root /etc/orchestrator.conf.json && \
    chmod a+x /etc/orchestrator.conf.json

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
EXPOSE 3000

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
