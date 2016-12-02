# Основные настройки
FROM ubuntu:16.04

# Переменные
# Путь к репозиторию
ENV cocktail_rep https://raw.githubusercontent.com/YakiYaki/CocktailManager/master
# Имя директории контейнера, имя директории проекта (имя проекта Django), имя приложения Django
ENV container_name=CocktailBotHome project_name=CocktailManager app_name=manager

RUN mkdir data
WORKDIR /data
RUN mkdir $container_name
WORKDIR $container_name

# Установка необходимых компонентов
RUN apt-get update
RUN apt-get install -y nginx python3 python3.5-dev python3-pip git

# Получаем список необходимых компонентов
ADD conf/requirements.txt requirements.txt

# Установка необходимых компонентов в ВО
RUN pip3 install -r requirements.txt

# Создаем проект Django
RUN django-admin.py startproject CocktailManager
WORKDIR $project_name

# Создаем приложение Django
RUN python3 manage.py startapp $app_name

# Переписываем setting.py проекта Django
COPY conf/settings.py CocktailManager/

# Ловим миграции
RUN python3 manage.py migrate

RUN mkdir static
RUN mkdir media

# Получаем файл с настройками nginx
ADD conf/CocktailManager-nginx.conf conf/CocktailManager-nginx.conf

# Получение сертификата
RUN apt-get install openssl
ADD ssl.ini ssl/ssl.ini
RUN openssl genrsa -out ssl/webhook_selfsigned_cert.key 2048
RUN /bin/sh -c "cat ssl/ssl.ini | openssl req -new -x509 -days 3650 -key ssl/webhook_selfsigned_cert.key -out ssl/webhook_selfsigned_cert.pem"

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CoctailManager-nginx.conf, чтобы nginx увидел его
RUN ln -s /data/$container_name/$project_name/conf/CocktailManager-nginx.conf /etc/nginx/sites-enabled/

# Добавление необходимых данных для uwsgi
ADD https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params uwsgi_params

# Собирает статические файлы в STATIC_ROOT
RUN /bin/sh -c "echo yes | python3 manage.py collectstatic"

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

USER root:root
WORKDIR /data/$container_name/$project_name
ADD conf/CocktailManager.ini CocktailManager.ini

# Запускаем наш сервер, рестартим nginx и запускаем консоль
ENTRYPOINT uwsgi --ini CocktailManager.ini & service nginx restart & clear & /bin/bash

EXPOSE 443
