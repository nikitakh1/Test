#!/bin/bash

# Добавляем репозиторий Elasticsearch и устанавливаем ключи
echo "Настройка репозитория Elasticsearch..."
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

# Установка Elasticsearch, Logstash и Kibana
echo "Установка Elasticsearch, Logstash и Kibana..."
yum install -y elasticsearch logstash kibana

# Установка Filebeat
echo "Установка Filebeat..."
yum install -y filebeat

# Настройка Filebeat для сбора логов Nginx
cat <<EOL > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log
  fields:
    log_type: nginx_access

output.logstash:
  hosts: ["localhost:5044"]
EOL

# Настройка Logstash для обработки и отправки логов в Elasticsearch
cat <<EOL > /etc/logstash/conf.d/nginx.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][log_type] == "nginx_access" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
}
EOL

# Запуск и автозапуск сервисов
echo "Запуск Elasticsearch, Logstash, Kibana и Filebeat..."
systemctl start elasticsearch
systemctl enable elasticsearch

systemctl start logstash
systemctl enable logstash

systemctl start kibana
systemctl enable kibana

systemctl start filebeat
systemctl enable filebeat

echo "Настройка ELK и Filebeat завершена."

