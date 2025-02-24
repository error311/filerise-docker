#!/bin/bash

echo "🚀 Running start.sh..."

# No need to copy the web app since it's included in the image at /var/www

# Ensure the uploads directory exists (this is the only persistent folder mapped in Unraid)
mkdir -p /var/www/uploads

# Fix permissions for the uploads folder
echo "🔑 Fixing permissions for /var/www/uploads..."
chown -R ${PUID:-99}:${PGID:-100} /var/www/uploads
chmod -R 775 /var/www/uploads

# (Optional) If you want to be extra sure, list the folder contents:
echo "📂 Contents of /var/www/uploads:"
ls -ld /var/www/uploads

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
