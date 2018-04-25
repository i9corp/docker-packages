FROM debian:9.2

RUN apt-get update
RUN apt-get install -y wget unzip git curl dos2unix nginx openssh-server proftpd createrepo vim apt-utils gzip mini-dinstall
RUN apt-get clean

ENV ROOT_DIR=/etc/i9corp/packages
ENV DEBIAN_DIR=${ROOT_DIR}/debian
ENV CENTOS_DIR=${ROOT_DIR}/centos
ENV CENTOS_DISTRIB=${CENTOS_DIR}/5.11/x86_64
ENV DEBIAN_POOL=${DEBIAN_DIR}/pool

COPY ./tools/sync-repo /usr/local/bin/sync-repo
RUN dos2unix /usr/local/bin/sync-repo
RUN chmod +x /usr/local/bin/sync-repo

COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages
RUN chmod +x /usr/local/bin/start-packages 

RUN mkdir -p ${DEBIAN_POOL}/updates ${DEBIAN_POOL}/internal ${DEBIAN_POOL}/non-free ${DEBIAN_POOL}/unstable ${DEBIAN_POOL}/stable

RUN mkdir -p ${CENTOS_DISTRIB}/base
RUN createrepo ${CENTOS_DISTRIB}/base

RUN mkdir -p ${CENTOS_DISTRIB}/updates
RUN createrepo ${CENTOS_DISTRIB}/updates

RUN mkdir -p ${DEBIAN_DIR}/mini-dinstall/incoming
COPY ./.mini-dinstall.conf ${DEBIAN_DIR}/.mini-dinstall.conf  

ARG REPO_PASSWD=123456
 
COPY ./signing.asc ${DEBIAN_DIR}/

COPY ./nginx/debian /etc/nginx/sites-available/debian
COPY ./proftpd/proftpd.conf /etc/proftpd/proftpd.conf
RUN dos2unix /etc/proftpd/proftpd.conf
RUN chmod 0644 /etc/proftpd/proftpd.conf

RUN unlink /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/debian /etc/nginx/sites-enabled/default
RUN ln -s ${DEBIAN_DIR}/.mini-dinstall.conf /etc/mini-dinstall.conf

RUN useradd -ms /bin/bash repo && echo "repo:${REPO_PASSWD}" | chpasswd

RUN chown -R repo:repo ${ROOT_DIR}

VOLUME [ "/etc/i9corp/packages" ]

# Debian
EXPOSE 80

#SSH
EXPOSE 22

#Proftpd
EXPOSE 21
EXPOSE 20

CMD ["/usr/local/bin/start-packages"]