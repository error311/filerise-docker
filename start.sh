#!/bin/bash

echo "🚀 Running start.sh..."

# Ensure /web exists and force copy if empty
if [ ! -d "/web" ] || [ -z "$(ls -A /web)" ]; then
    echo "🌱 /web is empty. Copying web app files from /var/www..."
    mkdir -p /web
    cp -R /var/www/* /web
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
