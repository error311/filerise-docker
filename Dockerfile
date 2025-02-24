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

# Default Unraid UID and GID (99:100)
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

# Ensure /var/www exists and remove any default Apache index.html
RUN mkdir -p /var/www && rm -f /var/www/index.html

# Download and extract the web app from GitHub into /var/www
RUN curl -L --retry 5 --retry-delay 10 \
    https://github.com/error311/multi-file-upload-editor/archive/refs/heads/master.zip -o /tmp/app.zip && \
    unzip /tmp/app.zip -d /var/www && \
    mv /var/www/multi-file-upload-editor-master/* /var/www && \
    rm -rf /tmp/app.zip /var/www/multi-file-upload-editor-master

# Copy the startup script into the image
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Configure Apache: Set DocumentRoot to /web so that the persistent volume is used
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /web' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory "/web">' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Expose ports
EXPOSE 80 443

# Run the startup script when the container launches
CMD ["/usr/local/bin/start.sh"]
