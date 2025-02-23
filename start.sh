#!/bin/bash

echo "🚀 Running start.sh..."

# Ensure web app files are present
if [ ! -f "/web/index.html" ]; then
    echo "🌱 /web is empty. Copying web app from /var/www/html..."
    mkdir -p /web
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
