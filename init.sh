#! /bin/bash

bot_token=$1
django_allowed_host=$2
django_secret_key=$3
django_superuser_pass=$4
db_name=$5
db_username=$6
db_password=$7

root_path=app
project_name=CocktailManager
email=brmgeometric@yandex.ru
bot_url="url=https://$django_allowed_host/bot/$bot_token"
cert_path="certificate=@/$root_path/ssl/webhook_selfsigned_cert.pem"
telegram_url=https://api.telegram.org/bot$bot_token/setWebhook

locale-gen "en_US.UTF-8"
export LC_ALL=en_US.UTF-8 
export LANGUAGE=en_US.UTF-8

# Находимся мы в /CocktailManager
# Установим PostgreSQL и nginx
apt-get update
apt-get -y upgrade
apt-get install -y postgresql-9.5 postgresql-server-dev-9.5 postgresql-contrib-9.5 nginx \
					python3 python3.5-dev python3-pip libpq-dev #\
#					docker.io

#systemctl enable docker
#systemctl start docker

#curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
#docker-compose --version

cd /
mkdir $root_path
cd $root_path
mv /$project_name/$project_name .
mv /$project_name/conf .
mkdir ssl

# Добавим необходимые данные для сертификата
echo "$django_allowed_host" >> conf/CM-ssl.ini 
echo "$email" >> conf/CM-ssl.ini
# Генерация сертификатов
cat conf/CM-ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_selfsigned_cert.key \
	-x509 -days 3650 -out ssl/webhook_selfsigned_cert.pem

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CM-nginx.conf, чтобы nginx увидел его
ln -s conf/CM-nginx.conf /etc/nginx/sites-enabled/

# Устанавливаем связь с Telegram
echo -e "\nDeleting WebHook ---->"
curl $telegram_url
echo -e "\nSetting WebHook ---->"
curl -F $bot_url -F $cert_path $telegram_url

# Устанавливаем необходимые компоненты
pip3 install -r conf/requirements.txt

#echo "        bot_token: $bot_token" >> docker-compose.yml
#echo "        django_allowed_host: $django_allowed_host" >> docker-compose.yml
#echo "        django_secret_key: \"$3\"" >> docker-compose.yml
#echo "        django_superuser_pass: $4" >> docker-compose.yml
#echo "        db_name: $5" >> docker-compose.yml
#echo "        db_username: $6" >> docker-compose.yml
#echo "        db_password: $7" >> docker-compose.yml

# Настройка и создание базы данных
echo "local   all             postgres                                md5" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='localhost'" >> /etc/postgresql/9.5/main/postgresql.conf
sudo -u postgres psql -f "conf/CM-db.ini"

cd $project_name
mkdir media
mkdir static

# Создаем из входных данных файл конфигурации
echo -e "[main]\ntoken = $bot_token\n[django]\nallowed_host = $django_allowed_host" > config.ini
echo -e "secret_key = $django_secret_key\n[DB]\ndb_name = $db_name\ndb_username = $db_username" >> config.ini
echo -e "db_password = $db_password" >> config.ini
cat config.ini

# Настраиваем приложение и создаем суперпользователя
python3 manage.py makemigrations
python3 manage.py migrate
chmod a+w log/manager.log
echo "from django.contrib.auth.models import User; User.objects.create_superuser('root', '$email', '$django_superuser_pass')"
echo "from django.contrib.auth.models import User; User.objects.create_superuser('root', '$email', '$django_superuser_pass')" | python3 manage.py shell
echo yes | python3 manage.py collectstatic

service nginx restart
# Запускаем Gunicorn
gunicorn -c ../conf/CM-gunicorn.conf.py CocktailManager.wsgi:application

echo -e "\n [DONE]"

exit 0