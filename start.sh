#!/bin/bash

echo "🚀 Running start.sh..."

# Check if web app files exist (ignore empty uploads folder)
if [ ! -f "/web/index.html" ]; then
    echo "🌱 Web app not found in /web. Downloading from GitHub..."

    # Ensure clean /web directory
    rm -rf /web/*
    mkdir -p /web

    # Download and extract the web app
    curl -L --retry 5 --retry-delay 10 \
        https://github.com/error311/multi-file-upload-editor/archive/refs/heads/master.zip -o /tmp/app.zip

    unzip /tmp/app.zip -d /tmp
    mv /tmp/multi-file-upload-editor-master/* /web
    rm -rf /tmp/app.zip /tmp/multi-file-upload-editor-master

    echo "✅ Web app successfully downloaded to /web."
else
    echo "📁 Web app already populated. Skipping download."
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
