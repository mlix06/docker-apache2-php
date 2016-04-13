FROM ubuntu:trusty
MAINTAINER Michael LIXON <michael.lixon@gmail.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        curl \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-mcrypt \
        php5-gd \
        php5-curl && \
    rm -rf /var/lib/apt/lists/*

RUN rm /var/www/html/index.html
RUN sed -i -e "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=apache/" /etc/apache2/envvars
RUN sed -i -e "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=apache/" /etc/apache2/envvars
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup --gid $GROUP_ID apache
RUN adduser --uid $USER_ID --gid $GROUP_ID --no-create-home --disabled-password --gecos '' apache

RUN chown apache:apache /var/www/html

CMD ["/usr/sbin/apachectl", "-DFOREGROUND"]

RUN a2enmod rewrite

RUN echo "<VirtualHost *:80> \n\
 DocumentRoot /var/www/html \n\
 <Directory /var/www/html> \n\
  Options Indexes FollowSymLinks MultiViews \n\
  AllowOverride All \n\
  Require all granted \n\
 </Directory> \n\
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf
