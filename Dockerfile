FROM debian:9.2

RUN apt-get update
RUN apt-get install -y wget unzip git curl mini-dinstall dos2unix dput nginx
RUN apt-get clean

COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages
RUN chmod +x /usr/local/bin/start-packages

ARG ROOT_DIR=/etc/i9corp/packages
ARG DEBIAN_DIR=${ROOT_DIR}/debian

RUN mkdir -p ${DEBIAN_DIR}/mini-dinstall/incoming
COPY ./.mini-dinstall.conf ${DEBIAN_DIR}/.mini-dinstall.conf  
 
COPY ./signing.asc ${DEBIAN_DIR}/
COPY ./dput.cf /root/.dput.cf

COPY ./nginx/debian /etc/nginx/sites-available/debian
RUN unlink /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/debian /etc/nginx/sites-enabled/default
RUN ln -s ${DEBIAN_DIR}/.mini-dinstall.conf /etc/mini-dinstall.conf

VOLUME [ "${DEBIAN_DIR}/mini-dinstall/incoming" ]

# Debian
EXPOSE 80

# Satis
EXPOSE 8080

CMD ["/usr/local/bin/start-packages"]