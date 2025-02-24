#!/bin/bash

echo "🚀 Running start.sh..."

# Since the web app code is baked into /var/www,
# we only need to ensure that the uploads folder exists and has proper permissions.

mkdir -p /var/www/uploads

# Fix permissions for /var/www/uploads
echo "🔑 Fixing permissions for /var/www/uploads..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/uploads
chmod -R 775 /var/www/uploads

# Optionally, you can also ensure the rest of /var/www has the correct permissions
echo "🔑 Fixing permissions for /var/www..."
find /var/www -type f -exec chmod 664 {} \;
find /var/www -type d -exec chmod 775 {} \;
chown -R ${PUID:-99}:${PGID:-100} /var/www

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
