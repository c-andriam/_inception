FROM alpine:3.21

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/conf.d /etc/nginx/certs

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/privkey.pem \
    -out /etc/nginx/certs/fullchain.pem \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=candriam.42.fr"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/run/nginx

COPY ./tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 443

ENTRYPOINT ["/script.sh"]

CMD ["nginx", "-g", "daemon off;"]
