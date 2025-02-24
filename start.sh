#!/bin/bash

echo "🚀 Running start.sh..."

# Check if /web is populated (by looking for index.html)
if [ ! -f "/web/index.html" ]; then
    echo "🌱 /web is empty. Copying web app from /var/www..."
    mkdir -p /web
    cp -R /var/www/* /web
    echo "✅ Web app successfully copied to /web."
else
    echo "📁 Web app already populated. Skipping copy."
fi

# Always fix permissions for /web
echo "🔑 Fixing permissions for /web..."
find /web -type f -exec chmod 664 {} \;
find /web -type d -exec chmod 775 {} \;
chown -R ${PUID:-99}:${PGID:-100} /web

# Ensure uploads folder exists
mkdir -p /web/uploads

# Create a symlink so that /var/www/uploads points to /web/uploads
if [ ! -L /var/www/uploads ]; then
    echo "🔗 Creating symlink: /var/www/uploads -> /web/uploads"
    ln -s /web/uploads /var/www/uploads
else
    echo "🔗 Symlink /var/www/uploads already exists."
fi

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
