#!/usr/bin/env sh

ECONUMO_CONFIG_API_URL="${ECONUMO_CONFIG_API_URL:=}"
LILTAG_CONFIG_URL="${LILTAG_CONFIG_URL:=}"
LILTAG_CACHE_TTL="${LILTAG_CACHE_TTL:=0}"
echo "window.econumoConfig = {
  API_URL: \"${ECONUMO_CONFIG_API_URL}\",
  LILTAG_CONFIG_URL: \"${LILTAG_CONFIG_URL}\",
  LILTAG_CACHE_TTL: ${LILTAG_CACHE_TTL},
}" > /usr/share/nginx/html/econumo-config.js

if [ ! -d "/var/www/var/db" ]; then
  mkdir -p /var/www/var/db
  su -s /bin/sh www-data -c "cd /var/www && php bin/console doctrine:database:create -q"
fi
chown -R www-data:www-data /var/www/ /usr/share/nginx/html/ /var/www/var/db

su -s /bin/sh www-data -c "cd /var/www && php bin/console doctrine:migrations:migrate --quiet --no-interaction --allow-no-migration"
su -s /bin/sh www-data -c "cd /var/www && php bin/console cache:clear"

/usr/bin/supervisord -n -c /etc/supervisord.conf