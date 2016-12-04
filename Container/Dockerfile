  # Основные настройки
FROM ubuntu:16.04
MAINTAINER brmgeometric@yandex.ru + N02@yandex.ru

# Переменные
# Путь к репозиторию
ENV cocktail_rep https://raw.githubusercontent.com/YakiYaki/CocktailManager/master
# Имя директории контейнера, имя директории проекта (имя проекта Django), имя приложения Django
ENV container_name=CocktailBotHome \
	project_name=CocktailManager \
	app_name=manager

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
	python3-pip git \
	curl &&\
	
	apt-get clean &&\
	rm -rf /var/lib/apt/lists/*

# Получаем список необходимых компонентов Python
ADD conf/requirements.txt requirements.txt
# Установка необходимых компонентов
RUN pip3 install -r requirements.txt

# Настраиваем базу данных PostgreSQL
RUN echo "local   all             postgres                                md5" >> \
	/etc/postgresql/9.5/main/pg_hba.conf &&\
	echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf &&\
	echo "listen_addresses='localhost'" >> /etc/postgresql/9.5/main/postgresql.conf

ARG bot_token

RUN mkdir data
WORKDIR /data
RUN mkdir $container_name
WORKDIR $container_name

# Создаем проект Django
RUN django-admin.py startproject $project_name
WORKDIR $project_name

# Создаем приложение Django
RUN python3 manage.py startapp $app_name
# Переписываем setting.py проекта Django
COPY conf/settings.py $project_name/
# Переписываем models.py приложения Django
COPY bot/models.py $app_name/
# Добавляем файл с созданием базы данных
COPY conf/db.ini conf/db.ini
# Добавляем файл с настройками nginx
COPY conf/CocktailManager-nginx.conf conf/CocktailManager-nginx.conf

# Создаем базу данных
USER postgres
RUN service postgresql start &&\
	psql -f "conf/db.ini" 

# Начальные настройки и связывание с базой данных приложения Django
USER root:root
RUN service postgresql start &&\
	sleep 45 &&\
	python3 manage.py makemigrations &&\
	python3 manage.py migrate

# Создаем папки для статики и медии
RUN mkdir static
RUN mkdir media

# Получение сертификата
RUN apt-get install openssl
COPY conf/ssl.ini ssl/ssl.ini
RUN openssl genrsa -out ssl/webhook_selfsigned_cert.key 2048
RUN cat ssl/ssl.ini | openssl req -new -x509 -days 3650 -key ssl/webhook_selfsigned_cert.key -out ssl/webhook_selfsigned_cert.pem

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CoctailManager-nginx.conf, чтобы nginx увидел его
RUN ln -s /data/$container_name/$project_name/conf/CocktailManager-nginx.conf /etc/nginx/sites-enabled/

# Добавление необходимых данных для uwsgi
ADD https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params uwsgi_params

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

WORKDIR /data/$container_name/$project_name
ADD conf/CocktailManager.ini CocktailManager.ini 

# Запускаем наш сервер, установливаем WebHook, запускаем сервер базы данных, рестартим nginx и запускаем консоль
ENTRYPOINT uwsgi --ini CocktailManager.ini &\
		   curl -F "url=https://student.bmstu.cloud/bot" \
				-F "certificate=/data/$container_name/$project_name/ssl/webhook_selfsigned_cert.pem" \
				https://api.telegram.org/bot$bot_token/setWebhook &\
		   service postgresql start &\
		   service nginx restart &\
		   clear &\
		   /bin/bash 

EXPOSE 443 5432
