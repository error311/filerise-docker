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

# Default Unraid UID and GID
ARG PUID=99
ARG PGID=100

# Ensure UID/GID are correct
RUN usermod -u ${PUID} www-data && groupmod -g ${PGID} www-data

# Install Apache, PHP, and required packages
RUN apt-get update && \
    apt-get install -y apache2 php php-json php-curl git ca-certificates openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache modules and configure PHP
RUN a2enmod rewrite && \
    echo "upload_max_filesize = ${UPLOAD_MAX_FILESIZE}" > /etc/php/8.1/apache2/conf.d/90-custom.ini && \
    echo "post_max_size = ${POST_MAX_SIZE}" >> /etc/php/8.1/apache2/conf.d/90-custom.ini

# Copy web app to temporary location
RUN git clone https://github.com/error311/multi-file-upload-editor.git /tmp/web

# Ensure startup script copies to /web if empty
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Apache site configuration
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /web' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory "/web">' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Expose ports
EXPOSE 80 443

# Run startup script
CMD ["/usr/local/bin/start.sh"]
