###############################################################################
# Dockerfile to build Custom Benchmark API container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="Custom benchmark API on Centos 7" \
      version="2.0.0"

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

# Install additional repository and add repository key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

###############################################################################
# BEGIN INSTALLATION
###############################################################################
# -----------------------------------------------------------------------------
# Install Golang packages
# -----------------------------------------------------------------------------
RUN yum install epel-release -y && \
    yum install golang make -y

ENV GOPATH /go

WORKDIR /go/src/github.com/swapbyt3s/MySQLSandbox/

# -----------------------------------------------------------------------------
# Assign environment variables
# -----------------------------------------------------------------------------
ENV MYSQL_HOST $MYSQL_HOST
ENV MYSQL_PORT $MYSQL_PORT
ENV MYSQL_USERNAME $MYSQL_USERNAME
ENV MYSQL_PASSWORD $MYSQL_PASSWORD
ENV MYSQL_SCHEMA $MYSQL_SCHEMA

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------
COPY main.go .
COPY Makefile .

RUN make deps
RUN make deploy

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*
############################## INSTALLATION END ###############################

EXPOSE 8080/tcp

# Start service on run container
ENTRYPOINT ["/go/src/github.com/swapbyt3s/MySQLSandbox/api"]
