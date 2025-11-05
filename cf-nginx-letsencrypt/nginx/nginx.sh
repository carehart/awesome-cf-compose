#!/bin/sh

set -e

if [ -z "$DOMAIN" ]; then
  echo "DOMAIN environment variable is not set"
  exit 1;
fi

use_dummy_certificate() {
  if grep -q "/etc/letsencrypt/live/$1" "/etc/nginx/sites/$1.conf"; then
    echo "Switching Nginx to use dummy certificate for $1"
    sed -i "s|/etc/letsencrypt/live/$1|/etc/nginx/sites/ssl/dummy/$1|g" "/etc/nginx/sites/$1.conf"
  fi
}

use_lets_encrypt_certificate() {
  if grep -q "/etc/nginx/sites/ssl/dummy/$1" "/etc/nginx/sites/$1.conf"; then
    echo "Switching Nginx to use Let's Encrypt certificate for $1"
    sed -i "s|/etc/nginx/sites/ssl/dummy/$1|/etc/letsencrypt/live/$1|g" "/etc/nginx/sites/$1.conf"
  fi
}

reload_nginx() {
  echo "Reloading Nginx configuration"
  nginx -s reload
}

wait_for_lets_encrypt() {
  until [ -d "/etc/letsencrypt/live/$1" ]; do
    echo "Waiting for Let's Encrypt certificates for $1"
    sleep 5s & wait ${!}
  done
  use_lets_encrypt_certificate "$1"
  reload_nginx
}

if [ ! -f /etc/nginx/sites/ssl/ssl-dhparams.pem ]; then
  mkdir -p "/etc/nginx/sites/ssl"
  openssl dhparam -out /etc/nginx/sites/ssl/ssl-dhparams.pem 2048
fi

echo "Checking configuration for $DOMAIN"

if [ ! -f "/etc/nginx/sites/$DOMAIN.conf" ]; then
  echo "Creating Nginx configuration file /etc/nginx/sites/$DOMAIN.conf"
  sed "s/\${domain}/$DOMAIN/g" /customization/site.conf.tpl > "/etc/nginx/sites/$DOMAIN.conf"
fi

if [ ! -f "/etc/nginx/sites/ssl/dummy/$DOMAIN/fullchain.pem" ]; then
  echo "Generating dummy certificate for $DOMAIN"
  mkdir -p "/etc/nginx/sites/ssl/dummy/$DOMAIN"
  printf "[dn]\nCN=${DOMAIN}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$DOMAIN\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > openssl.cnf
  openssl req -x509 -out "/etc/nginx/sites/ssl/dummy/$DOMAIN/fullchain.pem" -keyout "/etc/nginx/sites/ssl/dummy/$DOMAIN/privkey.pem" \
    -newkey rsa:2048 -nodes -sha256 \
    -subj "/CN=${DOMAIN}" -extensions EXT -config openssl.cnf
  rm -f openssl.cnf
fi

if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
  use_dummy_certificate "$DOMAIN"
  wait_for_lets_encrypt "$DOMAIN" &
else
  use_lets_encrypt_certificate "$DOMAIN"
fi

exec nginx -g "daemon off;"