#!/bin/bash

# Пароль для пользователя root в MySQL
MYSQL_ROOT_PASSWORD="-ваш пароль-" # Вы задаете переменную MYSQL_ROOT_PASSWORD с паролем для пользователя root в MySQL. Замените "-ваш пароль-" на фактический пароль.

# Установка MySQL Server
# Эта команда устанавливает MySQL сервер на вашем сервере CentOS 7.
sudo yum install -y mysql-server 

# Запускает службу MySQL после установки.
sudo systemctl start mysqld

# Настройка MySQL для запуска при загрузке системы.
sudo systemctl enable mysqld 

# Создание таблицы для проверки репликации
# Создает базу данных с именем "replication_test" на мастер-сервере.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE replication_test;" 

# Создает таблицу "test" в базе данных "replication_test" для последующей проверки репликации.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "USE replication_test; CREATE TABLE test (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(255));" 

# Настройка MySQL для репликации
# Создает пользователя "replication_user" с паролем "-Придумайте пароль-" и предоставляет ему права на репликацию.  Замените "-Придумайте пароль-" на желаемый пароль.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%' IDENTIFIED BY '-Придумайте пароль-';" 

# Применяет изменения в привилегиях MySQL.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;" 

# Блокирует таблицы на мастер-сервере для подготовки к созданию резервной копии.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH TABLES WITH READ LOCK;" 

# Получает текущую позицию бинарного лога и другую информацию о мастере, которую необходимо будет использовать на слейв-сервере.
master_status=$(mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS;") 

# Выводит сообщение с предложением записать информацию о мастере.
echo "Запишите следующие данные для использования на слейв-сервере:" 

# Выводит информацию о мастере, включая имя файла бинарного лога и его позицию, которые будут использоваться при настройке слейв-сервера.
echo "$master_status" 

# Разблокировка таблиц на мастере
# Разблокирует таблицы на мастер-сервере, позволяя им снова принимать записи.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "UNLOCK TABLES;" 
