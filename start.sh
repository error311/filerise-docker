#!/bin/bash

echo "🚀 Running start.sh..."

# Check if /web is populated (look for index.html as a key file)
if [ ! -f "/web/index.html" ]; then
    echo "🌱 /web is empty. Copying web app from /var/www..."
    mkdir -p /web
    cp -R /var/www/* /web
    echo "✅ Web app successfully copied to /web."
else
    echo "📁 /web already populated. Skipping copy."
fi

# Ensure uploads folder exists in /web
mkdir -p /web/uploads

# Fix permissions: Set files to 664 and directories to 775
echo "🔑 Fixing permissions for /web..."
find /web -type f -exec chmod 664 {} \;
find /web -type d -exec chmod 775 {} \;
chown -R ${PUID:-99}:${PGID:-100} /web

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
