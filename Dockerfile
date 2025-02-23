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

# Install Apache, PHP 8.1, and required extensions
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    apache2 \
    php \
    php-json \
    php-curl \
    ca-certificates \
    git \
    openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable Apache modules and configure PHP
RUN a2enmod rewrite && \
    echo "upload_max_filesize = ${UPLOAD_MAX_FILESIZE}" > /etc/php/8.1/apache2/conf.d/90-custom.ini && \
    echo "post_max_size = ${POST_MAX_SIZE}" >> /etc/php/8.1/apache2/conf.d/90-custom.ini

# Set up web directory
RUN git clone https://github.com/error311/multi-file-upload-editor.git /web && \
    rm -rf /web/.git && \
    mkdir -p /web/uploads

# Set correct ownership and permissions for Apache
RUN chown -R www-data:www-data /web && \
    chmod -R 755 /web && \
    chmod -R 755 /web/uploads

# Ensure Apache treats /web as its root
RUN rm -rf /var/www && ln -s /web /var/www

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

# Run Apache in foreground
CMD ["apachectl", "-D", "FOREGROUND"]
