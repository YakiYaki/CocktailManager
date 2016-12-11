#! /bin/bash
bot_token=$1
django_allowed_host=$2
project_name=CocktailManager
email=brmgeometric@yandex.ru
bot_url="url=https://$django_allowed_host/bot/$bot_token"
cert_path="certificate=@/$root_path/$container_name/$project_name/ssl/webhook_selfsigned_cert.pem"
telegram_url=https://api.telegram.org/bot$bot_token/setWebhook

locale-gen "en_US.UTF-8"
export LC_ALL=en_US.UTF-8 
export LANGUAGE=en_US.UTF-8

# Находимся мы в /CocktailManager
# Установим PostgreSQL и nginx
apt-get update
apt-get -y upgrade
#apt-get install -y postgresql-9.5 postgresql-server-dev-9.5 postgresql-contrib-9.5
apt-get install -y nginx python3 python3.5-dev python3-pip docker.io

systemctl enable docker
systemctl start docker

curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo "$django_allowed_host" >> conf/CM-ssl.ini 
echo "$email" >> conf/CM-ssl.ini

mkdir ssl
# Генерация сертификатов
cat conf/CM-ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_selfsigned_cert.key \
	-x509 -days 3650 -out ssl/webhook_selfsigned_cert.pem

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CM-nginx.conf, чтобы nginx увидел его
ln -s conf/CM-nginx.conf /etc/nginx/sites-enabled/

# Настраиваем базу данных PostgreSQL
#echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf
#echo "listen_addresses='localhost'" >> /etc/postgresql/9.5/main/postgresql.conf
#echo "local   all             postgres                                md5" >> /etc/postgresql/9.5/main/pg_hba.conf

curl $telegram_url
curl -F $bot_url -F $cert_path $telegram_url

echo "        bot_token: $bot_token" >> docker-compose.yml
echo "        django_allowed_host: $django_allowed_host" >> docker-compose.yml
echo "        django_secret_key: \"$3\"" >> docker-compose.yml
echo "        django_superuser_pass: $4" >> docker-compose.yml
echo "        db_name: $5" >> docker-compose.yml
echo "        db_username: $6" >> docker-compose.yml
echo "        db_password: $7" >> docker-compose.yml

echo "\n"
cat docker-compose.yml

exit 0