###############################################################################
# Dockerfile to build Apache 2.4 + PHP 5.6 container images
# Based on Centos 7
###############################################################################

# Set the base image to Centos 7
FROM centos:7

# File Author / Maintainer
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="Apache 2.4 with PHP 5.6 on Centos 7" \
      version="1.0"

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

# Install additional repository and add repository key
ADD https://rpms.remirepo.net/enterprise/remi.repo /etc/yum.repos.d/
RUN rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi2017
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# Update the repository sources list
RUN yum -y --setopt=tsflags=nodocs update

###############################################################################
# BEGIN INSTALLATION
###############################################################################
# -----------------------------------------------------------------------------
# Install and configure Apache 2.4
# -----------------------------------------------------------------------------
RUN yum -y --setopt=tsflags=nodocs install httpd

# -----------------------------------------------------------------------------
# Custom configuration for Apache 2.4
# -----------------------------------------------------------------------------
RUN sed -i \
        -e "s/\/var\/www\/html/\/var\/www/g" \
        -e '\#<Directory "/var/www/cgi-bin">#,\#</Directory>#d' \
      /etc/httpd/conf/httpd.conf

RUN { \
      echo ''; \
      echo '#'; \
      echo '# Custom configuration'; \
      echo '#'; \
      echo 'LogFormat \'; \
      echo '  "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" \'; \
      echo '  forwarded_for_combined'; \
      echo 'Options -Indexes'; \
      echo 'TraceEnable Off'; \
      echo 'UseCanonicalName On'; \
      echo 'UseCanonicalPhysicalPort On'; \
      echo 'ServerSignature Off'; \
      echo 'ServerTokens Prod'; \
      echo 'RewriteEngine On'; \
      echo 'KeepAlive Off'; \
      echo 'ServerName 127.0.0.1'; \
      echo 'ExtendedStatus On'; \
      echo 'DirectoryIndex index.php'; \
      echo 'DocumentRoot "/var/www"'; \
      echo '<Directory /var/www/>'; \
      echo '  DirectoryIndex index.php'; \
      echo '  Options +FollowSymLinks'; \
      echo '  AllowOverride All'; \
      echo '</Directory>'; \
    } >> /etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Disable all Apache modules and enable the minimum
# -----------------------------------------------------------------------------
RUN sed -i \
        -e 's~^\(LoadModule .*\)$~#\1~g' \
        -e 's~^#LoadModule alias_module ~LoadModule alias_module ~g' \
        -e 's~^#LoadModule alias_module ~LoadModule alias_module ~g' \
        -e 's~^#LoadModule authz_core_module ~LoadModule authz_core_module ~g' \
        -e 's~^#LoadModule authz_host_module ~LoadModule authz_host_module ~g' \
        -e 's~^#LoadModule deflate_module ~LoadModule deflate_module ~g' \
        -e 's~^#LoadModule dir_module ~LoadModule dir_module ~g' \
        -e 's~^#LoadModule expires_module ~LoadModule expires_module ~g' \
        -e 's~^#LoadModule filter_module ~LoadModule filter_module ~g' \
        -e 's~^#LoadModule headers_module ~LoadModule headers_module ~g' \
        -e 's~^#LoadModule log_config_module ~LoadModule log_config_module ~g' \
        -e 's~^#LoadModule mime_module ~LoadModule mime_module ~g' \
        -e 's~^#LoadModule rewrite_module ~LoadModule rewrite_module ~g' \
        -e 's~^#LoadModule setenvif_module ~LoadModule setenvif_module ~g' \
        -e 's~^#LoadModule slotmem_shm_module ~LoadModule slotmem_shm_module ~g' \
        -e 's~^#LoadModule status_module ~LoadModule status_module ~g' \
        -e 's~^#LoadModule unixd_module ~LoadModule unixd_module ~g' \
        /etc/httpd/conf.modules.d/00-base.conf

# -----------------------------------------------------------------------------
# Remove unnecessary files and folders
# -----------------------------------------------------------------------------
RUN rm -r -f /var/www/cgi-bin/ \
             /var/www/error/ \
             /var/www/html/ \
             /var/www/icons/ \
             /etc/httpd/conf.d/README \
             /etc/httpd/conf.d/autoindex.conf \
             /etc/httpd/conf.d/userdir.conf \
             /etc/httpd/conf.d/welcome.conf

# -----------------------------------------------------------------------------
# Install and configure PHP 5.6
# -----------------------------------------------------------------------------
RUN yum -y \
        --setopt=tsflags=nodocs \
        --enablerepo=remi \
        install php56 \
                php56-php \
                php56-php-common \
                php56-php-cli \
                php56-php-mysqlnd \
                php56-php-mbstring \
                php56-php-xml \
                php56-php-xmlrpc \
                php56-php-devel \
                php56-php-pear \
                php56-php-pecl-uuid

RUN sed -i \
        -e 's~^short_open_tag = Off~short_open_tag = On~g' \
        -e 's~^error_reporting = .*$~error_reporting = E_ERROR | E_WARNING | E_PARSE~g' \
        -e 's~^display_errors = Off~display_errors = On~g' \
        -e 's~^display_errors = Off~display_errors = On~g' \
        -e 's~^expose_php = On~expose_php = Off~g' \
    /opt/remi/php56/root/etc/php.ini

ENV PATH=$PATH:/opt/remi/php56/root/usr/bin

# -----------------------------------------------------------------------------
# Copy code for benchmark
# -----------------------------------------------------------------------------
COPY index.php /var/www/index.php

# -----------------------------------------------------------------------------
# Clear
# -----------------------------------------------------------------------------
RUN yum -y clean all && \
    rm -rf /var/cache/yum/*
############################## INSTALLATION END ###############################

# Set the working directory to /var/www
WORKDIR /var/www

# Define mount point
VOLUME ["/var/www", "/var/log/httpd/"]

# Expose the default http port
EXPOSE 80

# Start service on run container
ENTRYPOINT ["/usr/sbin/apachectl", "-DFOREGROUND"]
