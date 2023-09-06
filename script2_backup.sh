#!/bin/bash

# Укажите учетные данные для доступа к базе данных
DB_USER="your_username"
DB_PASSWORD="your_password"
DB_HOST="localhost"

# Укажите каталог, в который будут сохраняться бэкапы
BACKUP_DIR="/path/backup/directory"

# Получите текущую дату и время для именования файлов бэкапа
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Создайте файл для хранения информации о позиции бинлога
BINLOG_INFO_FILE="${BACKUP_DIR}/binlog_info_${TIMESTAMP}.txt"

# Получите список всех баз данных
DATABASES=$(mysql -u${DB_USER} -p${DB_PASSWORD} -h${DB_HOST} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")

# Создайте бэкап для каждой базы данных по таблицам
for DB in $DATABASES; do
  TABLES=$(mysql -u${DB_USER} -p${DB_PASSWORD} -h${DB_HOST} -e "USE ${DB}; SHOW TABLES;" | grep -v "Tables_in_")
  for TABLE in $TABLES; do
    BACKUP_FILE="${BACKUP_DIR}/${DB}_${TABLE}_${TIMESTAMP}.sql"
    mysqldump --skip-lock-tables --single-transaction --master-data=2 -u${DB_USER} -p${DB_PASSWORD} -h${DB_HOST} ${DB} ${TABLE} > "${BACKUP_FILE}"
    gzip "${BACKUP_FILE}"
  done
done

# Запишите информацию о позиции бинлога в файл
mysql -u${DB_USER} -p${DB_PASSWORD} -h${DB_HOST} -e "SHOW MASTER STATUS" > "${BINLOG_INFO_FILE}"