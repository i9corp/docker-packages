FROM debian:9.2

RUN apt-get update
RUN apt-get install -y wget unzip git curl mini-dinstall dos2unix dput nginx openssh-server proftpd createrepo vim
RUN apt-get clean

COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages
RUN chmod +x /usr/local/bin/start-packages

ARG ROOT_DIR=/etc/i9corp/packages
ARG DEBIAN_DIR=${ROOT_DIR}/debian
ARG CENTOS_DIR=${ROOT_DIR}/centos
ARG CENTOS_DISTRIB=${CENTOS_DIR}/5.11/x86_64 

RUN mkdir -p ${CENTOS_DISTRIB}/base
RUN mkdir -p ${CENTOS_DISTRIB}/updates

RUN createrepo ${CENTOS_DISTRIB}/base
RUN createrepo ${CENTOS_DISTRIB}/updates

RUN mkdir -p ${DEBIAN_DIR}/mini-dinstall/incoming
COPY ./.mini-dinstall.conf ${DEBIAN_DIR}/.mini-dinstall.conf  

ARG REPO_PASSWD=123456
 
COPY ./signing.asc ${DEBIAN_DIR}/
COPY ./dput.cf /root/.dput.cf

COPY ./nginx/debian /etc/nginx/sites-available/debian
COPY ./proftpd/proftpd.conf /etc/proftpd/proftpd.conf
RUN dos2unix /etc/proftpd/proftpd.conf
RUN chmod 0644 /etc/proftpd/proftpd.conf

RUN unlink /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/debian /etc/nginx/sites-enabled/default
RUN ln -s ${DEBIAN_DIR}/.mini-dinstall.conf /etc/mini-dinstall.conf

RUN useradd -ms /bin/bash repo && echo "repo:${REPO_PASSWD}" | chpasswd

VOLUME [ "${DEBIAN_DIR}/mini-dinstall/incoming" ]

# Debian
EXPOSE 80

#SSH
EXPOSE 22

#Proftpd
EXPOSE 21
EXPOSE 20

CMD ["/usr/local/bin/start-packages"]