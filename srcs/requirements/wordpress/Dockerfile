FROM alpine:3.21

RUN apk update && apk add --no-cache \
		php81 php81-fpm \
		php81-mysqli \
		php81-json \
		php81-openssl \
		php81-curl \
		php81-gd php81-mbstring php81-xml \
		php81-session \
		curl tar \

RUN mkdir -p /var/www/html && \
		chown -R www-data:www-data /var/www/html && \
		chmod 755 /var/www/html

WORKDIR /var/www/html

RUN curl -o wordpress.tar.gz https://downloads.wordpress.org/release/wordpress-6.8.1.tar.gz \
		&& tar -xzf wordpress.tar.gz --strip-components=1 \
		&& rm wordpress.tar.gz

COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

EXPOSE 9000

CMD ["php-fpm81", "-F", "-R"]
