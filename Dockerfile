  # Основные настройки
FROM ubuntu:16.04
MAINTAINER Artur Galikhaydarov (brmgeometric@yandex.ru), Nikita Boyarskikh N02@yandex.ru

# Входные параметры
# ВНИМАНИЕ! При вводе через --build-arg django_secret_key необходимо экранировать 
# все скобочки ('(', ')') и знаки доллара ('$')
ARG bot_token
ARG django_allowed_host
ARG django_secret_key
ARG db_name
ARG db_username
ARG db_password

# Переменные
# Имя директории контейнера, имя директории проекта (имя проекта Django), имя приложения Django
ENV project_name CocktailManager
ENV app_name manager
ENV token bot${bot_token}
ENV bot_url "url=https://${django_allowed_host}/bot/${bot_token}"
ENV telegram_url https://api.telegram.org/${token}/setWebhook
ENV email brmgeometric@yandex.ru

# Установка необходимых компонентов
RUN locale-gen "en_US.UTF-8" &&\
 	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 &&\
	
	apt-get update &&\
	apt-get install -y postgresql-9.5 \
	postgresql-server-dev-9.5 \
	postgresql-contrib-9.5 \
	nginx \
	python3 \
	python3.5-dev \
	python3-pip \
	libpcre3 \
	libpcre3-dev \
	git \
	curl \
	openssl &&\
	
	apt-get clean &&\
	rm -rf /var/lib/apt/lists/*


RUN mkdir data
WORKDIR /data

# Получаем список необходимых компонентов Python
COPY conf/requirements.txt requirements.txt
# Установка необходимых компонентов
RUN pip3 install -r requirements.txt

# Создаем папку для статики
RUN mkdir /data/static
# Копируем проект Django
COPY CocktailManager/ CocktailManager/
WORKDIR $project_name

# Создание файла конфигурации с секретными данными
RUN echo "[main]\n token = ${bot_token}\n[django]\n allowed_host = ${django_allowed_host}\n \
secret_key = ${django_secret_key}\n[DB]\n db_name = ${db_name}\n db_username = ${db_username}\n \
db_password = ${db_password}" > config.ini

# Раскомментируйте, чтобы просмотреть созданый файл
# RUN cat config.ini

# Добавляем файл с созданием базы данных
COPY conf/CM-db.ini conf/CM-db.ini
# Добавляем файл с настройками nginx
COPY conf/CM-nginx.conf conf/CM-nginx.conf
# Добавляем настройки сертификата
COPY conf/CM-ssl.ini ssl/CM-ssl.ini
# Добавляем необходимые данные для uwsgi
ADD https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params uwsgi_params
# Добавляем настройки uwsgi
COPY conf/CM-uwsgi.ini conf/CM-uwsgi.ini
# Добавим данные для сертификата
RUN echo "${django_allowed_host}\n${email}" >> ssl/CM-ssl.ini

# Генерирование сертификата
RUN cat ssl/CM-ssl.ini | openssl req -newkey rsa:2048 -sha256 -nodes -keyout ssl/webhook_selfsigned_cert.key \
	-x509 -days 3650 -out ssl/webhook_selfsigned_cert.pem

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CM-nginx.conf, чтобы nginx увидел его
RUN ln -s /data/$project_name/conf/CM-nginx.conf /etc/nginx/sites-enabled/

# Настраиваем базу данных PostgreSQL
RUN echo "local   all             postgres                                md5" >> \
	/etc/postgresql/9.5/main/pg_hba.conf &&\
	echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf &&\
	echo "listen_addresses='localhost'" >> /etc/postgresql/9.5/main/postgresql.conf

# Создаем базу данных
USER postgres
RUN service postgresql start &&\
	psql -f "conf/CM-db.ini" 

# Начальные настройки и связывание с базой данных приложения Django
USER root:root
RUN service postgresql start &&\
	sleep 45 &&\
	python3 manage.py makemigrations &&\
	python3 manage.py migrate

# Собирает статические файлы в STATIC_ROOT приложения Django
RUN echo yes | python3 manage.py collectstatic

# Добавляем наше приложение в автозапуск
WORKDIR /etc
RUN rm -f rc.local
ADD conf/rc.local /etc/rc.local

# Устанавливаем uwsgi глобально
RUN pip3 install uwsgi

# Создаём директорию для логов uwsgi
RUN mkdir /var/uwsgi
RUN mkdir /var/uwsgi/log
RUN chown www-data:www-data -R /var/uwsgi

WORKDIR /data/$project_name
RUN chmod a+w manager.log 


# Запускаем наш сервер, сброс WebHook, установливаем WebHook, запускаем сервер базы данных, 
# рестартим nginx и запускаем консоль
ENTRYPOINT uwsgi --ini conf/CM-uwsgi.ini &\
		   curl ${telegram_url} &&\
		   curl -F ${bot_url} \
				-F "certificate=@/data/$container_name/$project_name/ssl/webhook_selfsigned_cert.pem" \
				${telegram_url} &\
			sleep 10 &\
		   service postgresql start &\
		   sleep 10 &\
		   service nginx restart &\
		   sleep 5 &\
		   /bin/bash

EXPOSE 443 5432
