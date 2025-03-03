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
    POST_MAX_SIZE=5G

# Default Unraid UID and GID (override via container env variables if needed)
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

# syntax=docker/dockerfile:1.4
FROM ubuntu:22.04 AS builder

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create /var/www directory and remove default index.html if it exists
RUN mkdir -p /var/www && rm -f /var/www/html/index.html

# Clone the private repository using the BuildKit secret
# The token is read securely from /run/secrets/git_token
RUN --mount=type=secret,id=git_token \
    git clone --depth 1 https://x-access-token:$(cat /run/secrets/git_token)@github.com/error311/multi-file-upload-editor.git /var/www

# Final stage: copy the app files into a clean image
FROM ubuntu:22.04

# Copy files from the builder stage
COPY --from=builder /var/www /var/www

# Set ownership and permissions
RUN chown -R www-data:www-data /var/www && chmod -R 775 /var/www

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]

# Configure Apache: set DocumentRoot to /var/www
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

# Expose default ports 80 and 443
EXPOSE 80 443

# Copy the startup script into the image
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Start the container using the startup script
CMD ["/usr/local/bin/start.sh"]
