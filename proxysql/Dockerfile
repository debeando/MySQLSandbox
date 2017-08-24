###############################################################################
# Dockerfile to build HAProxy container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="HAProxy on Centos 7" \
      version="1.0"

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

###############################################################################
# BEGIN INSTALLATION
###############################################################################
# -----------------------------------------------------------------------------
# Install additional packages
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install which wget unzip sysvinit-tools

# -----------------------------------------------------------------------------
# Install the Percona repository package
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona

# -----------------------------------------------------------------------------
# Install ProxySQL and MySQL Client
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install proxysql Percona-Server-client-57

# -----------------------------------------------------------------------------
# Copy custom config
# -----------------------------------------------------------------------------
COPY proxysql.cnf /etc/proxysql.cnf

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
EXPOSE 3306 6032

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
