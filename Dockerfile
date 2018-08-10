FROM sourceallies/php-node-docker:latest

RUN mkdir -p /var/log/supervisor /var/run/php

RUN useradd -u 1001 -G www-data -m sai

COPY src /var/www/app
WORKDIR /var/www/app
RUN touch /var/www/app/storage/logs/laravel.log
RUN chmod 664 /var/www/app/storage/logs/laravel.log

# FIXME: Takes forever when rebuilding and vendor or node_modules exists
RUN chown -R sai:www-data /var/www/app

# Nginx Configuration File
ADD conf/nginx.conf /etc/nginx/conf.d/app.conf

# Supervisord Configuration Files
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 80
EXPOSE 443

USER sai
RUN echo "" >> ~/.bashrc && \
    echo "source /tmp/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

USER root
RUN echo "" >> ~/.bashrc && \
    echo "source /tmp/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

ENTRYPOINT "/usr/bin/supervisord"
