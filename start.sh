#!/bin/bash

echo "🚀 Running start.sh..."

# Update config.php based on environment variables
CONFIG_FILE="/var/www/config.php"
if [ -f "$CONFIG_FILE" ]; then
  echo "🔄 Updating config.php based on environment variables..."
  if [ -n "$TIMEZONE" ]; then
    echo "   Setting TIMEZONE to $TIMEZONE"
    sed -i "s|define('TIMEZONE',[[:space:]]*'[^']*');|define('TIMEZONE', '$TIMEZONE');|" "$CONFIG_FILE"
  fi
  if [ -n "$DATE_TIME_FORMAT" ]; then
    echo "   Setting DATE_TIME_FORMAT to $DATE_TIME_FORMAT"
    sed -i "s|define('DATE_TIME_FORMAT',[[:space:]]*'[^']*');|define('DATE_TIME_FORMAT', '$DATE_TIME_FORMAT');|" "$CONFIG_FILE"
  fi
  if [ -n "$TOTAL_UPLOAD_SIZE" ]; then
    echo "   Setting TOTAL_UPLOAD_SIZE to $TOTAL_UPLOAD_SIZE"
    sed -i "s|define('TOTAL_UPLOAD_SIZE',[[:space:]]*'[^']*');|define('TOTAL_UPLOAD_SIZE', '$TOTAL_UPLOAD_SIZE');|" "$CONFIG_FILE"
  fi
  if [ -n "$USERS_DIR" ]; then
  echo "   Setting USERS_DIR to $USERS_DIR"
  sed -i "s|define('USERS_DIR',[[:space:]]*'[^']*');|define('USERS_DIR', '$USERS_DIR');|" "$CONFIG_FILE"
  fi
fi

# Update PHP upload limits at runtime if TOTAL_UPLOAD_SIZE is set.
if [ -n "$TOTAL_UPLOAD_SIZE" ]; then
  echo "🔄 Updating PHP upload limits with TOTAL_UPLOAD_SIZE=$TOTAL_UPLOAD_SIZE"
  echo "upload_max_filesize = $TOTAL_UPLOAD_SIZE" > /etc/php/8.1/apache2/conf.d/90-custom.ini
  echo "post_max_size = $TOTAL_UPLOAD_SIZE" >> /etc/php/8.1/apache2/conf.d/90-custom.ini
fi

# Update Apache ports if environment variables are provided
if [ -n "$HTTP_PORT" ]; then
  echo "🔄 Setting Apache HTTP port to $HTTP_PORT"
  sed -i "s/Listen 80/Listen $HTTP_PORT/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:$HTTP_PORT>/" /etc/apache2/sites-available/000-default.conf
fi

if [ -n "$HTTPS_PORT" ]; then
  echo "🔄 Setting Apache HTTPS port to $HTTPS_PORT"
  sed -i "s/Listen 443/Listen $HTTPS_PORT/" /etc/apache2/ports.conf
  # If you have an HTTPS VirtualHost, update it similarly.
fi

echo "📁 Web app is served from /var/www."

# Ensure the uploads folder exists in /var/www
mkdir -p /var/www/uploads

# Fix permissions for the uploads folder
echo "🔑 Fixing permissions for /var/www/uploads..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/uploads
chmod -R 775 /var/www/uploads

# Ensure the users folder exists
mkdir -p /var/www/users
echo "🔑 Fixing permissions for /var/www/users..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/users
chmod -R 775 /var/www/users

# Optionally, fix permissions for the rest of /var/www
echo "🔑 Fixing permissions for /var/www..."
find /var/www -type f -exec chmod 664 {} \;
find /var/www -type d -exec chmod 775 {} \;
chown -R ${PUID:-99}:${PGID:-100} /var/www

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
