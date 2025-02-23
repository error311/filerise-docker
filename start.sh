#!/bin/bash

echo "🚀 Running start.sh..."

# Ensure /web exists and populate if empty
if [ ! -d "/web" ] || [ -z "$(ls -A /web)" ]; then
    echo "🌱 /web is empty. Populating with web app code from /var/www/html..."
    cp -R /var/www/html/* /web
else
    echo "✅ /web already populated. Skipping copy."
fi

# Fix permissions
echo "🔑 Setting permissions..."
chown -R www-data:users /web
chmod -R 775 /web/uploads

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
