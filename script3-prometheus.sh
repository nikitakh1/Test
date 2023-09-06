#!/bin/bash

# Устанавливаем необходимые зависимости
echo "Установка зависимостей..."
yum install -y wget tar

# Установка Prometheus
echo "Установка Prometheus..."

# Загрузка Prometheus
PROMETHEUS_VERSION="2.37.9"
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Распаковка и установка
tar xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64/
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

# Удаление временных файлов
cd ..
rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*
mkdir /etc/prometheus
mkdir /var/lib/prometheus

# Настройка конфигурации
cat <<EOL > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
    - targets: ['localhost:9100']
EOL

# Запуск Prometheus
echo "Запуск Prometheus..."
nohup prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus &

# Установка node_exporter
echo "Установка node_exporter..."

# Загрузка node_exporter
NODE_EXPORTER_VERSION="1.2.2"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Распаковка и установка
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cd node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/
cp node_exporter /usr/local/bin/

# Удаление временных файлов
cd ..
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*

# Запуск node_exporter
echo "Запуск node_exporter..."
nohup node_exporter &

echo "Установка и настройка завершены."

