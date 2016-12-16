#! /bin/bash

bot_token=$1
host=$2
port=$3

root_path=app
rep_name=CocktailManager
project_name=bar
email=brmgeometric@yandex.ru

path=bot/$bot_token
bot_url="url=https://$host:$port/$path"
cert_path="certificate=@/$root_path/$project_name/ssl/webhook_cert.pem"
telegram_url=https://api.telegram.org/bot$bot_token/setWebhook

locale-gen "en_US.UTF-8"
export LC_ALL=en_US.UTF-8 
export LANGUAGE=en_US.UTF-8

apt-get update
apt-get -y upgrade
apt-get install -y python3 python3.5-dev python3-pip libpq-dev nginx  libpcre3 libpcre3-dev

# Находимся мы в CoctailManager/bar (репозиторий)
# Устанавливаем необходимые компоненты
pip3 install -r ../conf/requirements.txt

cd /
mkdir $root_path
cd $root_path
mv /$rep_name/bar .

cd $project_name
mv /$rep_name/conf .
mkdir ssl
mkdir log
mkdir static
mkdir media
touch log/gerror.log
touch log/gaccess.log
chmod a+w log/gerror.log
chmod a+w log/gaccess.log
mv conf/gunicorn.service /etc/systemd/system/gunicorn.service

# Создаем из входных данных файл конфигурации
echo -e "[main]\ntoken = $bot_token\nhost = $host\nport = $port" > config.ini
#cat config.ini

# Добавим необходимые данные для сертификата
echo "$host" >> conf/ssl.ini 
echo "$email" >> conf/ssl.ini
# Генерация сертификатов
cat conf/ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_cert.key \
	-x509 -days 3650 -out ssl/webhook_cert.pem


# nginx
# Удаляем настройки по умолчанию и устанавливаем новые
unlink /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
ln -s /$root_path/$project_name/conf/nginx.conf /etc/nginx/sites-enabled/
# Тестируем конфигурацию
nginx -t

# Устанавливаем связь с Telegram
echo -e "\nDeleting WebHook ---->"
curl $telegram_url
echo -e "\nSetting WebHook ---->"
curl -F $bot_url -F $cert_path $telegram_url
echo ""

chown -R www-data:www-data /$root_path

exit 0