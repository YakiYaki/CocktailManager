#! /bin/bash
django_allowed_host=$2
project_name=CocktailManager
email=brmgeometric@yandex.ru

locale-gen "en_US.UTF-8"
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Находимся мы в /CocktailManager
# Установим PostgreSQL и nginx
apt-get update
apt-get install -y postgresql-9.5 postgresql-server-dev-9.5 postgresql-contrib-9.5 \
				   nginx python3 python3.5-dev python3-pip docker.io

systemctl enable docker
systemctl start docker

echo "$django_allowed_host" >> conf/CM-ssl.ini 
echo "$email" >> conf/CM-ssl.ini

mkdir ssl
# Генерация сертификатов
cat conf/CM-ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_selfsigned_cert.key \
	-x509 -days 3650 -out ssl/webhook_selfsigned_cert.pem

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CM-nginx.conf, чтобы nginx увидел его
ln -s /$project_name/conf/CM-nginx.conf /etc/nginx/sites-enabled/

# Настраиваем базу данных PostgreSQL
echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='localhost'" >> /etc/postgresql/9.5/main/postgresql.conf

psql -U postgres -f "conf/CM-db.ini"

docker build --build-arg bot_token=$1 --build-arg django_allowed_host=$2 --build-arg django_secret_key="$3" \
			 --build-arg django_superuser_pass=$4 \
			 --build-arg db_name=$5 \
			 --build-arg db_username=$6 \
			 --build-arg db_password=$7 \

			 -t prod_test .
exit 0