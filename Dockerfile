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

# Install Apache, PHP, Git, and required dependencies
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
    git --version && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ensure /var/www exists and remove any default Apache index.html
RUN mkdir -p /var/www && rm -f /var/www/html/index.html

# Define GitHub Token as an Argument (passed during build)
ARG GIT_TOKEN
RUN git clone --depth 1 https://${GIT_TOKEN}@github.com/error311/multi-file-upload-editor.git /var/www

# Fix ownership and permissions for /var/www so files are writable by www-data
RUN chown -R www-data:www-data /var/www && chmod -R 775 /var/www

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
