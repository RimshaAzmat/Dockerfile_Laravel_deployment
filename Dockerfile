# Use the official PHP image with Apache for PHP 8.1
FROM php:8.1-apache
# Install necessary PHP extensions and tools
RUN apt-get update && apt-get install -y \
libpng-dev libjpeg-dev libfreetype6-dev \
libzip-dev unzip git libicu-dev \
&& docker-php-ext-configure gd --with-freetype --with-jpeg \
&& docker-php-ext-install gd zip pdo pdo_mysql \
&& apt-get clean && rm -rf /var/lib/apt/lists/*
# Enable Apache mod_rewrite
RUN a2enmod rewrite
# Set the working directory to the root of your Laravel project
WORKDIR /var/www/html
# Copy the Laravel project into the container
COPY . /var/www/html
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
&& mv composer.phar /usr/local/bin/composer
# Install PHP dependencies
RUN composer install
# Copy .env.example to .env
RUN cp .env.example .env
# Generate Laravel application key
RUN php artisan key:generate
# Set proper permissions for the entire project directory
RUN chown -R www-data:www-data /var/www/html
RUN find /var/www/html -type f -exec chmod 644 {} \;
RUN find /var/www/html -type d -exec chmod 755 {} \;
# Set correct permissions for storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cac he
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
# Expose port 80
EXPOSE 80
# Add this line to your Dockerfile before the CMD ["apache2-foreground"]
RUN sed -i ’s|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|’ /et c/apache2/sites-available/000-default.conf
# Add this to your Dockerfile before the CMD ["apache2-foreground"]
RUN echo "<Directory /var/www/html>\n\
AllowOverride All\n\
Require all granted\n\
</Directory>" > /etc/apache2/conf-available/laravel.conf \
&& a2enconf laravel
# Start Apache
CMD ["apache2-foreground"]
