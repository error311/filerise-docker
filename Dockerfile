# syntax=docker/dockerfile:1.4
#############################
# Builder Stage – clone repo
#############################
FROM ubuntu:22.04 AS builder

# Install only what is needed to clone the repo
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create /var/www directory (remove any default index.html)
RUN mkdir -p /var/www && rm -f /var/www/html/index.html

# Clone the public repository (no token needed)
RUN git clone --depth 1 https://github.com/error311/filerise.git /var/www

#############################
# Final Stage – runtime image
#############################
FROM ubuntu:22.04

LABEL by=error311

# Set basic environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root \
    LC_ALL=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    TERM=xterm \
    UPLOAD_MAX_FILESIZE=5G \
    POST_MAX_SIZE=5G \
    PERSISTENT_TOKENS_KEY=default_please_change_this_key

# Default Unraid UID and GID (override via container env variables if needed)
ARG PUID=99
ARG PGID=100

# Install Apache, PHP, and required packages (including php-zip)
# This layer updates and upgrades packages, then cleans up in one command.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      apache2 \
      php \
      php-json \
      php-curl \
      php-zip \
      ca-certificates \
      curl \
      git \
      openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ensure the Apache user (www-data) has the desired UID/GID
RUN set -eux; \
    if [ "$(id -u www-data)" != "${PUID}" ]; then \
        usermod -u ${PUID} www-data || echo "UID already set"; \
    fi; \
    if [ "$(id -g www-data)" != "${PGID}" ]; then \
        groupmod -g ${PGID} www-data || echo "GID already set"; \
    fi; \
    usermod -g ${PGID} www-data

# Copy the web app from the builder stage
COPY --from=builder /var/www /var/www

# Fix ownership and permissions for /var/www
RUN chown -R www-data:www-data /var/www && chmod -R 775 /var/www

# Configure Apache using a heredoc (this avoids quoting issues)
RUN cat <<'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www
    <Directory "/var/www">
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

# Enable necessary Apache modules (e.g., rewrite)
RUN a2enmod rewrite

# Expose default ports 80 and 443
EXPOSE 80 443

# Copy the startup script into the image and make it executable
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Start the container using the startup script
CMD ["/usr/local/bin/start.sh"]
