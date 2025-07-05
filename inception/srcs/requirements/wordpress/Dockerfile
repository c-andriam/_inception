FROM alpine:3.21

RUN apk update && apk add --no-cache \
		php82 \
		php82-fpm \
		php82-mysqli \
		php82-json \
		php82-curl \
		php82-dom \
		php82-exif \
		php82-fileinfo \
		php82-mbstring \
		php82-openssl \
		php82-xml \
		php82-zip \
		php82-phar \
		curl \
		tar \
		mariadb-client

RUN mkdir -p /run/php && \
	sed -i 's/;clear_env = no/clear_env = no/g' /etc/php82/php-fpm.d/www.conf && \
	sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php82/php-fpm.d/www.conf

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

RUN curl -O https://wordpress.org/latest.tar.gz \
		&& tar -xzf latest.tar.gz \
		&& mv wordpress/* . \
		&& rm -rf  wordpress latest.tar.gz \
		&& chown -R nobody:nobody /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php82/php-fpm.d/www.conf

COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 9000

ENTRYPOINT ["/script.sh"]

CMD ["php-fpm82", "-F"]
