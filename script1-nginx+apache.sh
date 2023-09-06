#!/bin/bash

echo "1. Настройка балансировки нагрузки между Apache и Nginx"

# Обновление системы
echo "Обновляем систему..."
yum update -y

# Установка EPEL репозитория
echo "Установка EPEL репозитория..."
yum install epel-release -y

# Установка Nginx
echo "Установка Nginx..."
yum install nginx -y
systemctl start nginx
systemctl enable nginx

# Установка Apache
echo "Установка Apache..."
yum install httpd -y
systemctl start httpd
systemctl enable httpd

# Настройка балансировки нагрузки в Nginx
echo "Настройка балансировщика нагрузки Nginx..."
cat <<EOL > /etc/nginx/conf.d/loadbalancer.conf
upstream backend {
    server 127.0.0.1:8080;  # Apache слушает на порту 8080
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
EOL

# Настройка Apache для прослушивания на порту 8080
sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf

# Перезапуск обоих серверов
echo "Перезапуск Nginx и Apache..."
systemctl restart nginx
systemctl restart httpd

echo "Настройка завершена."

