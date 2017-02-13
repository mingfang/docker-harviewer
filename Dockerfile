FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc
RUN echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt install oracle-java8-unlimited-jce-policy && \
    rm -r /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Node
RUN wget -O - https://nodejs.org/dist/v7.1.0/node-v7.1.0-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm
ENV NODE_PATH=/usr/local/lib/node_modules PATH=$PATH:/node/bin

#Ant
RUN wget -O - https://www.apache.org/dist/ant/binaries/apache-ant-1.9.9-bin.tar.gz | tar zx
RUN mv *ant* ant

#Nginx and PHP
RUN apt-get install -y nginx php-fpm
COPY default /etc/nginx/sites-enabled/
RUN mkdir -p /run/php

#HAR Viewer
RUN wget -O - https://github.com/janodvarko/harviewer/archive/2.0.17.tar.gz | tar zx && \
    cd /harviewer* && \
    /ant/bin/ant build && \
    mv webapp-build/* /var/www/html/ && \
    rm -r /harviewer*

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

