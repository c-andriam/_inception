#!/bin/sh

mkdir -p /etc/nginx/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/certs/privkey.pem \
  -out /etc/nginx/certs/fullchain.pem \
  -subj "/C=MO/L=KH/O=42/OU=student/CN=${DOAMIN_NAME}"


sed -i "s/\${DOMAIN_NAME}/$DOMAIN_NAME/g" /etc/nginx/conf.d/default.conf


nginx -g "daemon off;"
