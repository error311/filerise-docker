#!/bin/bash

echo "🚀 Running start.sh..."

# Ensure /web exists and download web app if empty
if [ ! -d "/web" ] || [ -z "$(ls -A /web)" ]; then
    echo "🌱 /web is empty. Downloading and extracting web app from GitHub..."
    mkdir -p /web
    curl -L --retry 5 --retry-delay 10 \
        https://github.com/error311/multi-file-upload-editor/archive/refs/heads/master.zip -o /tmp/app.zip

    # Extract and move files to /web
    unzip /tmp/app.zip -d /tmp
    mv /tmp/multi-file-upload-editor-master/* /web
    rm -rf /tmp/app.zip /tmp/multi-file-upload-editor-master

    echo "✅ Web app downloaded and extracted to /web."
else
    echo "📁 /web already populated. Skipping download."
fi

# Fix permissions
echo "🔑 Setting permissions for /web..."
chown -R www-data:users /web
chmod -R 775 /web/uploads

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
