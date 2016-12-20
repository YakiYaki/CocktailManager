#! /bin/bash

if [[ $1 == "" ]]
then 
	echo "Please, enter bot token!"
	exit 1
else
	bot_token=$1
fi

if [[ $2 == "" ]]
then
	echo "Set host = 127.0.0.1"
	host="127.0.0.1"
else
	host=$2
fi

if [[ $3 == "" ]]
then
	echo "Set port = 8443"
	port="8443"
else
	port=$3
fi

db_name=$4
db_user=$5
db_pass=$6

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

echo -e "Installing what we need:\nfor system"
apt-get update > /dev/null
apt-get -y upgrade > /dev/null
if apt-get install -y postgresql-9.5 postgresql-server-dev-9.5 postgresql-contrib-9.5 \
				   python3 python3.5-dev python3-pip libpq-dev nginx \
				   libpcre3 libpcre3-dev > /dev/null	
then echo -e "\t[OK]"
else echo -e "can't install :(\nexit" & exit 1
fi

# Находимся мы в CoctailManager/bar (репозиторий)
# Устанавливаем необходимые компоненты
echo "for app"
if pip3 install -r ../conf/requirements.txt > /dev/null
then echo -e "\t[OK]"
else echo -e "can't install :(\nexit" & exit 1
fi

cd /
mkdir $root_path
cd $root_path
mv /$rep_name/bar .

cd $project_name
mv /$rep_name/conf .
mkdir ssl
mkdir log
mkdir static
mkdir template
mkdir media
touch log/gerror.log
touch log/gaccess.log
chmod a+w log/gerror.log
chmod a+w log/gaccess.log
mv conf/gunicorn.service /etc/systemd/system/gunicorn.service

# Создаем из входных данных файл конфигурации
echo -e "[main]\ntoken = $bot_token\nhost = $host\nport = $port\nkey = 'lolololo'" > config.ini
echo -e "[db]\nname = $db_name\nuser = $db_user\npass = $db_pass" >> config.ini
#cat config.ini

# Добавим необходимые данные для сертификата
echo "$host" >> conf/ssl.ini 
echo "$email" >> conf/ssl.ini
# Генерация сертификатов
echo "Generating self-signed certificate"
if cat conf/ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_cert.key \
	-x509 -days 3650 -out ssl/webhook_cert.pem > /dev/null
then echo -e "\t[OK]"
else echo -e "can't generate certificate :(\nexit" & exit 1
fi

# nginx
# Удаляем настройки по умолчанию и устанавливаем новые
unlink /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
ln -s /$root_path/$project_name/conf/nginx.conf /etc/nginx/sites-enabled/
# Тестируем конфигурацию
#nginx -t

# Устанавливаем связь с Telegram
echo -e "Deleting WebHook"
curl $telegram_url
echo -e "\nSetting WebHook"
curl -F $bot_url -F $cert_path $telegram_url
echo

# postgresql
# Добавляем необходимые настройки и создаем базу
echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='localhost'" >> /etc/postgresql/9.5/main/postgresql.conf
echo "Creating database"
if sudo -u postgres psql -f "conf/db.ini" > /dev/null
then echo -e "\t[OK]"
else echo -e "can't create database :(\nexit" & exit 1
fi
chown -R www-data:www-data /$root_path

echo "Setting up database"
if python3 manage.py db init > /dev/null
then if python3 manage.py db migrate > /dev/null
	then if python3 manage.py db upgrade > /dev/null
		then echo -e "\t[OK]"
		else echo -e "can't upgrade database :(\nexit" & exit 1
		fi
	else echo -e "can't migrate database :(\nexit" & exit 1
	fi
else echo -e "can't init database :(\nexit" & exit 1
fi

python3 manage.py db init
python3 manage.py db migrate
python3 manage.py db upgrade

exit 0