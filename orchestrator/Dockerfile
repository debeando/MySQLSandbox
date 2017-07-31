FROM ubuntu:xenial
MAINTAINER swapbyt3s@gmail.com

LABEL vendor="Swapbyt3s" \
      description="GitHub Orchestrator on Ubuntu Xenial" \
      version="2.1.5"

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y apt-utils wget
RUN wget --quiet https://github.com/github/orchestrator/releases/download/v2.1.5/orchestrator_2.1.5_amd64.deb && \
    wget --quiet https://github.com/github/orchestrator/releases/download/v2.1.5/orchestrator-cli_2.1.5_amd64.deb
RUN dpkg --install orchestrator_2.1.5_amd64.deb && \
    dpkg --install orchestrator-cli_2.1.5_amd64.deb

COPY orchestrator.conf.json /etc/orchestrator.conf.json
RUN chown root:root /etc/orchestrator.conf.json && \
    chmod a+x /etc/orchestrator.conf.json

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh

RUN rm -rf orchestrator_2.1.5_amd64.deb && \
    rm -rf orchestrator-cli_2.1.5_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3000

ENTRYPOINT ["/root/entrypoint.sh"]
