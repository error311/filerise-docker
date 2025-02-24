#!/bin/bash

echo "🚀 Running start.sh..."

# Path to the web app configuration file
CONFIG_FILE="/var/www/config.php"

# If config.php exists, update it based on environment variables
if [ -f "$CONFIG_FILE" ]; then
  echo "🔄 Updating config.php based on environment variables..."
  if [ -n "$TIMEZONE" ]; then
    echo "   Setting TIMEZONE to $TIMEZONE"
    sed -i "s/define('TIMEZONE', '[^']*');/define('TIMEZONE', '$TIMEZONE');/" "$CONFIG_FILE"
  fi
  if [ -n "$DATE_TIME_FORMAT" ]; then
    echo "   Setting DATE_TIME_FORMAT to $DATE_TIME_FORMAT"
    sed -i "s/define('DATE_TIME_FORMAT', '[^']*');/define('DATE_TIME_FORMAT', '$DATE_TIME_FORMAT');/" "$CONFIG_FILE"
  fi
  if [ -n "$TOTAL_UPLOAD_SIZE" ]; then
    echo "   Setting TOTAL_UPLOAD_SIZE to $TOTAL_UPLOAD_SIZE"
    sed -i "s/define('TOTAL_UPLOAD_SIZE', '[^']*');/define('TOTAL_UPLOAD_SIZE', '$TOTAL_UPLOAD_SIZE');/" "$CONFIG_FILE"
  fi
fi

# If TOTAL_UPLOAD_SIZE is set, update PHP's upload limits at runtime.
if [ -n "$TOTAL_UPLOAD_SIZE" ]; then
  echo "🔄 Updating PHP upload limits with TOTAL_UPLOAD_SIZE=$TOTAL_UPLOAD_SIZE"
  echo "upload_max_filesize = $TOTAL_UPLOAD_SIZE" > /etc/php/8.1/apache2/conf.d/90-custom.ini
  echo "post_max_size = $TOTAL_UPLOAD_SIZE" >> /etc/php/8.1/apache2/conf.d/90-custom.ini
fi

# Check if /web is populated (by looking for index.html)
if [ ! -f "/web/index.html" ]; then
    echo "🌱 /web is empty. Copying web app from /var/www..."
    mkdir -p /web
    cp -R /var/www/* /web
    echo "✅ Web app successfully copied to /web."
else
    echo "📁 Web app already populated. Skipping copy."
fi

# Ensure the uploads folder exists in /web
mkdir -p /web/uploads

# Create a symlink so that /var/www/uploads points to /web/uploads
if [ ! -L /var/www/uploads ]; then
    echo "🔗 Creating symlink: /var/www/uploads -> /web/uploads"
    ln -s /web/uploads /var/www/uploads
else
    echo "🔗 Symlink /var/www/uploads already exists."
fi

# Always fix permissions for /web
echo "🔑 Fixing permissions for /web..."
find /web -type f -exec chmod 664 {} \;
find /web -type d -exec chmod 775 {} \;
chown -R ${PUID:-99}:${PGID:-100} /web

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
