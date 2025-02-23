#!/bin/bash

echo "🚀 Running start.sh..."

# Ensure /web exists and populate if empty
if [ ! -f "/web/index.html" ]; then
    echo "🌱 Web app not found in /web. Copying from /var/www/html..."
    mkdir -p /web

    # Remove default Apache placeholder
    if [ -f "/var/www/html/index.html" ]; then
        echo "🗑️ Removing default Apache index.html..."
        rm -f /var/www/html/index.html
    fi

    # Copy the web app to /web
    cp -R /var/www/html/* /web
else
    echo "📁 Web app already populated. Skipping copy."
fi

# Ensure uploads folder exists
mkdir -p /web/uploads

# Set correct permissions
echo "🔑 Setting ownership to PUID=${PUID:-99} and PGID=${PGID:-100}..."
chown -R ${PUID:-99}:${PGID:-100} /web
chmod -R 775 /web

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
