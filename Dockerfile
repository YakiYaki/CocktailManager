  # Основные настройки
FROM ubuntu:16.04
MAINTAINER Artur Galikhaydarov (brmgeometric@yandex.ru), Nikita Boyarskikh N02@yandex.ru

# Входные параметры
# ВНИМАНИЕ! При вводе через --build-arg django_secret_key необходимо экранировать 
# все скобочки ('(', ')') и знаки доллара ('$')
ARG bot_token
ARG django_allowed_host
ARG django_secret_key
ARG django_superuser_pass
ARG db_name
ARG db_username
ARG db_password

# Переменные
# Имя директории контейнера, имя директории проекта (имя проекта Django), имя приложения Django
ENV root_path app
ENV project_name CocktailManager
ENV email=brmgeometric@yandex.ru

# Установка необходимых компонентов
RUN locale-gen "en_US.UTF-8" &&\
 	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN apt-get update &&\
	apt-get install -y python3 python3.5-dev python3-pip libpq-dev &&\
	apt-get clean

RUN mkdir $root_path
WORKDIR /$root_path
RUN mkdir log

# Добавляем сертификат
COPY ssl/webhook_selfsigned_cert.pem ssl/webhook_selfsigned_cert.pem
# Получаем список необходимых компонентов Python
COPY conf/requirements.txt requirements.txt
# Добавляем настройки uwsgi
COPY conf/CM-gunicorn.conf.py conf/CM-gunicorn.conf.py
# Копируем проект Django
COPY CocktailManager/ CocktailManager/
WORKDIR $project_name

# Создание файла конфигурации с секретными данными для Django приложения
RUN echo "[main]\n token = ${bot_token}\n[django]\n allowed_host = ${django_allowed_host}\n \
secret_key = ${django_secret_key}\n[DB]\n db_name = ${db_name}\n db_username = ${db_username}\n \
db_password = ${db_password}" > config.ini

#RUN cat config.ini

# Установка необходимых компонентов
RUN pip3 install -r ../requirements.txt

EXPOSE 8002

# Запускаем наш сервер, сброс WebHook, установливаем WebHook, запускаем сервер базы данных, 
# рестартим nginx и запускаем консоль
ENTRYPOINT python3 manage.py makemigrations &&\
		   python3 manage.py migrate &&\
		   chmod a+w log/manager.log &&\
		   echo "from django.contrib.auth.models import User; User.objects.create_superuser('root', '${email}', '${django_superuser_pass}')" | python3 manage.py shell &&\
		   echo yes | python3 manage.py collectstatic &&\
		   gunicorn -c CM-gunicorn.conf.py CocktailManager.wsgi:application &&\
		   /bin/bash
