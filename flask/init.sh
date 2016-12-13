#! /bin/bash

bot_token=$1
host=$2
port=$3

root_path=app
project_name=CocktailManager
email=brmgeometric@yandex.ru

path=bot/$bot_token
bot_url="url=https://$host:$port/$path"
cert_path="certificate=@/$root_path/ssl/webhook_selfsigned_cert.pem"
telegram_url=https://api.telegram.org/bot$bot_token/setWebhook

locale-gen "en_US.UTF-8"
export LC_ALL=en_US.UTF-8 
export LANGUAGE=en_US.UTF-8

apt-get update
apt-get -y upgrade
apt-get install -y python3 python3.5-dev python3-pip libpq-dev libpcre3 libpcre3-dev

# Устанавливаем необходимые компоненты
pip3 install -r conf/requirements.txt

cd /
mkdir $root_path
cd $root_path
mv /$project_name/conf .
mv /$project_name/flask .
mv /$project_name/$project_name/config.py flask/config.py
mkdir ssl
mkdir log

# Добавим необходимые данные для сертификата
echo "$host" >> conf/CM-ssl.ini 
echo "$email" >> conf/CM-ssl.ini
# Генерация сертификатов
cat conf/CM-ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_selfsigned_cert.key \
	-x509 -days 3650 -out ssl/webhook_selfsigned_cert.pem

# Устанавливаем связь с Telegram
echo -e "\nDeleting WebHook ---->"
curl $telegram_url
echo -e "\nSetting WebHook ---->"
curl -F $bot_url -F $cert_path $telegram_url
echo ""

cd flask
# Создаем из входных данных файл конфигурации
echo -e "[main]\ntoken = $bot_token\nhost = $host\nport = $port" > config.ini
cat config.ini

cd ..
touch log/gerror.log
touch log/gaccess.log
chmod a+w log/gerror.log
chmod a+w log/gaccess.log

mv conf/gunicorn.service /etc/systemd/system/gunicorn.service

chown -R www-data:www-data *

exit 0