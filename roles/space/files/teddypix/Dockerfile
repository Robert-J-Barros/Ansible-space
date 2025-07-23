# Use official PHP 8.2 image with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install required system dependencies and PHP extensions
RUN apt-get update && apt-get install -y libicu-dev && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo_mysql intl

# Enable OPCache extension
RUN docker-php-ext-install opcache

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy project files excluding the devops folder
COPY . /var/www/html

# Copy config file
COPY ./.env /var/www/html
COPY ./.htaccess /var/www/html
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./helpers.php /var/www/html/vendor/laravel/framework/src/Illuminate/Foundation/helpers.php
COPY ./GenerateSignedUploadUrl.php /var/www/html/vendor/livewire/livewire/src/Features/SupportFileUploads/GenerateSignedUploadUrl.php

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html