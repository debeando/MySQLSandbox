###############################################################################
# Dockerfile to build ProxySQL container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="ProxySQL on Centos 7" \
      version="1.4.3"

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

# Install additional repository and add repository key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

###############################################################################
# BEGIN INSTALLATION
###############################################################################
# -----------------------------------------------------------------------------
# Install additional packages
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install which wget unzip sysvinit-tools

RUN yum install epel-release -y && \
    yum install jq -y

# -----------------------------------------------------------------------------
# Install the Percona repository package
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install https://repo.percona.com/percona/yum/percona-release-1.0-7.noarch.rpm
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona

# -----------------------------------------------------------------------------
# Install ProxySQL and MySQL Client
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install proxysql Percona-Server-client-57
COPY proxysql.cnf /etc/proxysql.cnf

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
COPY handler.sh /root/handler.sh
RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/handler.sh
RUN touch /root/handler.log

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*
############################## INSTALLATION END ###############################

# Set the working directory to /var/www
WORKDIR /root

# Expose the default http port
EXPOSE 3306/tcp 6032/tcp

# Start service on run container
ENTRYPOINT ["/root/entrypoint.sh"]
