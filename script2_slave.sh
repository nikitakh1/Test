#!/bin/bash


# Задание пароля для пользователя root в MySQL
MYSQL_ROOT_PASSWORD="-ваш пароль-" # Вы задаете переменную MYSQL_ROOT_PASSWORD с паролем для пользователя root в MySQL. Замените "-ваш пароль-" на фактический пароль.

# Установка MySQL Server
# В этом блоке выполняется установка MySQL Server, запуск службы MySQL и включение ее в автозапуск. 
# MySQL Server устанавливается с помощью команды yum, запускается и активируется после перезагрузки.
sudo yum install -y mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Задание данных мастера, полученные на этапе настройки мастера
# Здесь вам нужно указать фактические значения master_log_file_from_master и master_log_position_from_master, которые вы получили на предыдущем этапе настройки мастера.
MASTER_LOG_FILE="master_log_file_from_master"
MASTER_LOG_POS=master_log_position_from_master


# Настройка MySQL на слейве
# Этот блок настраивает MySQL на слейв-сервере для репликации. Вы должны указать фактические значения master_hostname_or_ip, replication_user и replication_password, 
# которые соответствуют вашей настройке мастера. 
# Также устанавливаются значения MASTER_LOG_FILE и MASTER_LOG_POS, которые вы получили с мастера. Затем репликация запускается командой START SLAVE.
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CHANGE MASTER TO MASTER_HOST='master_hostname_or_ip', MASTER_USER='replication_user', MASTER_PASSWORD='replication_password', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "START SLAVE;"

# Проверка статуса репликации
# Этот блок выводит на экран статус репликации, чтобы убедиться, что репликация успешно настроена и работает. 
# Статус репликации содержит информацию о текущем состоянии репликации, и вы можете использовать эту информацию для мониторинга репликации.
slave_status=$(mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW SLAVE STATUS\G")
echo "Replication status:"
echo "$slave_status"
