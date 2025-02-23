#!/bin/bash

# Ensure /web exists and populate if empty
if [ ! -d "/web" ] || [ -z "$(ls -A /web)" ]; then
    echo "Populating /web with web app code..."
    cp -R /tmp/web/* /web
else
    echo "/web already populated."
fi

# Start Apache
exec apachectl -D FOREGROUND
