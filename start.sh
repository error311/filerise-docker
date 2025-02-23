#!/bin/bash

echo "🚀 Running start.sh..."

# 🟢 Check if /web has any app files (ignore empty folders)
if [ -z "$(find /web -type f -not -path "/web/uploads/*")" ]; then
    echo "🌱 /web is empty. Copying web app from /var/www/html..."

    # Ensure clean copy
    rm -rf /web/*
    cp -R /var/www/html/* /web

    echo "✅ Web app successfully copied to /web."
else
    echo "📁 Web app already populated. Skipping copy."
fi

# Ensure uploads folder exists
mkdir -p /web/uploads

# 🟢 Fix permissions for all files and folders
echo "🔑 Fixing file and directory permissions..."
find /web -type f -exec chmod 664 {} \;    # Files: -rw-rw-r--
find /web -type d -exec chmod 775 {} \;    # Directories: drwxrwxr-x

# Ensure users.txt has correct permissions
echo "✍️ Ensuring users.txt is writable..."
touch /web/users.txt
chown 99:100 /web/users.txt
chmod 664 /web/users.txt

# Start Apache
echo "🔥 Starting Apache..."
exec apachectl -D FOREGROUND
