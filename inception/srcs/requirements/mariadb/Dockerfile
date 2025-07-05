FROM alpine:3.21

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql

COPY ./conf/my.cnf /etc/my.cnf

RUN echo "[mysqld]" > /etc/my.cnf.d/mariadb-server.cnf && \
	echo "bind-address=0.0.0.0" >> /etc/my.cnf.d/mariadb-server.cnf && \
	echo "port=3306" >> /etc/my.cnf.d/mariadb-server.cnf

COPY ./tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 3306

ENTRYPOINT ["/script.sh"]
