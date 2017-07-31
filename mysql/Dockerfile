FROM ubuntu:xenial
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="MySQL Server on Ubuntu Xenial" \
      version="5.7"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y apt-utils \
                       tzdata \
                       vim && \
    apt-get install -y mysql-server-5.7 \
                       mysql-client-core-5.7 \
                       mysql-utilities

COPY my.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
RUN chown root:root /etc/mysql/mysql.conf.d/mysqld.cnf

COPY entrypoint.sh /root/entrypoint.sh
COPY replicate.sh /root/replicate.sh
RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/replicate.sh

RUN rm -rf /var/lib/apt/lists/*

EXPOSE 3306

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["mysqld"]
