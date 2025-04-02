#!/bin/bash

echo "🚀 Running start.sh..."

# Warn if default persistent tokens key is in use
if [ "$PERSISTENT_TOKENS_KEY" = "default_please_change_this_key" ]; then
  echo "⚠️ WARNING: Using default persistent tokens key. Please override PERSISTENT_TOKENS_KEY for production."
fi

# Update config.php based on environment variables
CONFIG_FILE="/var/www/config.php"
if [ -f "$CONFIG_FILE" ]; then
  echo "🔄 Updating config.php based on environment variables..."
  if [ -n "$TIMEZONE" ]; then
    echo "   Setting TIMEZONE to $TIMEZONE"
    sed -i "s|define('TIMEZONE',[[:space:]]*'[^']*');|define('TIMEZONE', '$TIMEZONE');|" "$CONFIG_FILE"
  fi
  if [ -n "$DATE_TIME_FORMAT" ]; then
    echo "🔄 Setting DATE_TIME_FORMAT to $DATE_TIME_FORMAT"
    sed -i "s|define('DATE_TIME_FORMAT',[[:space:]]*'[^']*');|define('DATE_TIME_FORMAT', '$DATE_TIME_FORMAT');|" "$CONFIG_FILE"
  fi
  if [ -n "$TOTAL_UPLOAD_SIZE" ]; then
    echo "🔄 Setting TOTAL_UPLOAD_SIZE to $TOTAL_UPLOAD_SIZE"
    sed -i "s|define('TOTAL_UPLOAD_SIZE',[[:space:]]*'[^']*');|define('TOTAL_UPLOAD_SIZE', '$TOTAL_UPLOAD_SIZE');|" "$CONFIG_FILE"
  fi
  if [ -n "$SECURE" ]; then
  echo "🔄 Setting SECURE to $SECURE"
  sed -i "s|\$envSecure = getenv('SECURE');|\$envSecure = '$SECURE';|" "$CONFIG_FILE"
  fi
  if [ -n "$SHARE_URL" ]; then
  echo "🔄 Setting SHARE_URL to $SHARE_URL"
  sed -i "s|define('SHARE_URL',[[:space:]]*'[^']*');|define('SHARE_URL', '$SHARE_URL');|" "$CONFIG_FILE"
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
  sed -i "s/^Listen 80$/Listen $HTTP_PORT/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:$HTTP_PORT>/" /etc/apache2/sites-available/000-default.conf
fi

if [ -n "$HTTPS_PORT" ]; then
  echo "🔄 Setting Apache HTTPS port to $HTTPS_PORT"
  sed -i "s/^Listen 443$/Listen $HTTPS_PORT/" /etc/apache2/ports.conf
fi

# Update Apache ServerName if environment variable is provided
if [ -n "$SERVER_NAME" ]; then
  echo "🔄 Setting Apache ServerName to $SERVER_NAME"
  echo "ServerName $SERVER_NAME" >> /etc/apache2/apache2.conf
else
  echo "🔄 Setting Apache ServerName to default: FileRise"
  echo "ServerName FileRise" >> /etc/apache2/apache2.conf
fi

echo "Final /etc/apache2/ports.conf content:"
cat /etc/apache2/ports.conf

echo "📁 Web app is served from /var/www."

# Ensure the uploads folder exists in /var/www
mkdir -p /var/www/uploads
echo "🔑 Fixing permissions for /var/www/uploads..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/uploads
chmod -R 775 /var/www/uploads

# Ensure the users folder exists in /var/www
mkdir -p /var/www/users
echo "🔑 Fixing permissions for /var/www/users..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/users
chmod -R 775 /var/www/users

# Ensure the metadata folder exists in /var/www
mkdir -p /var/www/metadata
echo "🔑 Fixing permissions for /var/www/metadata..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/metadata
chmod -R 775 /var/www/metadata

# Create users.txt only if it doesn't already exist (preserving persistent data)
if [ ! -f /var/www/users/users.txt ]; then
  echo "ℹ️ users.txt not found in persistent storage; creating new file..."
  echo "" > /var/www/users/users.txt
  chown ${PUID:-99}:${PGID:-100} /var/www/users/users.txt
  chmod 664 /var/www/users/users.txt
else
  echo "ℹ️ users.txt already exists; preserving persistent data."
fi

# Create createdTags.json only if it doesn't already exist (preserving persistent data)
if [ ! -f /var/www/metadata/createdTags.json ]; then
  echo "ℹ️ createdTags.json not found in persistent storage; creating new file..."
  echo "[]" > /var/www/metadata/createdTags.json
  chown ${PUID:-99}:${PGID:-100} /var/www/metadata/createdTags.json
  chmod 664 /var/www/metadata/createdTags.json
else
  echo "ℹ️ createdTags.json already exists; preserving persistent data."
fi

# Optionally, fix permissions for the rest of /var/www
echo "🔑 Fixing permissions for /var/www..."
find /var/www -type f -exec chmod 664 {} \;
find /var/www -type d -exec chmod 775 {} \;
chown -R ${PUID:-99}:${PGID:-100} /var/www

echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
