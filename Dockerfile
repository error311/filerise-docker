FROM ubuntu:22.04
LABEL by=error311

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root \
    LC_ALL=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    TERM=xterm \
    UPLOAD_MAX_FILESIZE=5G \
    POST_MAX_SIZE=5G

# Default Unraid UID and GID (should match Unraid’s "nobody:users")
ARG PUID=99
ARG PGID=100

# Ensure the Apache user (www-data) has the desired UID/GID
RUN set -eux; \
    if [ "$(id -u www-data)" != "${PUID}" ]; then \
        usermod -u ${PUID} www-data || echo "UID already set"; \
    fi; \
    if [ "$(id -g www-data)" != "${PGID}" ]; then \
        groupmod -g ${PGID} www-data || echo "GID already set"; \
    fi; \
    usermod -g ${PGID} www-data

# Install Apache, PHP, and required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      apache2 \
      php \
      php-json \
      php-curl \
      ca-certificates \
      curl \
      unzip \
      git \
      openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Remove any default Apache index (if present) and ensure /var/www exists
RUN mkdir -p /var/www && rm -f /var/www/html/index.html

# Download and extract your web app from GitHub into /var/www
RUN mkdir -p /var/www/html && \
    curl -L --retry 5 --retry-delay 10 \
      https://github.com/error311/multi-file-upload-editor/archive/refs/heads/master.zip -o /tmp/app.zip && \
    unzip /tmp/app.zip -d /var/www && \
    mv /var/www/multi-file-upload-editor-master/* /var/www && \
    rm -rf /tmp/app.zip /var/www/multi-file-upload-editor-master

# Ensure the uploads directory exists within the web app
RUN mkdir -p /var/www/uploads

# (Optional) If you wish, you can fix permissions during build—but we'll fix uploads at startup.
# RUN chown -R ${PUID}:${PGID} /var/www/uploads && chmod -R 775 /var/www/uploads

# Configure Apache: Set DocumentRoot to /var/www so your app is served from there.
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory "/var/www">' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Expose ports
EXPOSE 80 443

# Copy the startup script into the image
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Start the container by running the startup script
CMD ["/usr/local/bin/start.sh"]
