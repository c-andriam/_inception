FROM alpine:3.21

RUN apk update && \
		apk add --no-cache \
		mariadb mariadb-client \

COPY conf/my.cnf /etc/my.cnf

RUN mkdir -p /var/lib/mysql && \
		chown -R mysql:mysql /var/lib/mysql && \
		chmod 755 /var/lib/mysql

EXPOSE 3306

CMD ["mysqld", "--user=mysql", "--console"]
