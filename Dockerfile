FROM debian:9.2

RUN apt-get update
RUN apt-get install -y wget unzip git curl php mini-dinstall apache2 php php-xml php-mbstring dos2unix
RUN apt-get clean

COPY ./tools/composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN mkdir -p /var/www/composer
RUN composer create-project composer/satis --stability=dev --keep-vcs /var/www/composer
COPY ./tools/satis.json /var/www/composer/satis.json
RUN /var/www/composer/bin/satis build /var/www/composer/satis.json /var/www/composer/release/

RUN mkdir -p /var/www/debian/mini-dinstall/incoming
COPY ./tools/mini-dinstall.conf /var/www/debian/mini-dinstall/mini-dinstall.conf
COPY ./tools/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages
RUN chmod +x /usr/local/bin/start-packages
RUN chown -R www-data:www-data /var/www
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
COPY ./tools/dos2unix_7.3.4-3_amd64.deb /var/www/debian/mini-dinstall/incoming
RUN a2enmod rewrite
RUN a2enconf fqdn

VOLUME [ "/var/www/" ]

# Debian
EXPOSE 80

# Satis
EXPOSE 8080

CMD ["/usr/local/bin/start-packages"]