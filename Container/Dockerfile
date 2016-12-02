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
RUN apt-get install -y nginx python3 python3.5-dev python3-pip python3-venv git

# Создание виртуального окружения (ВО)
RUN python3 -m venv env
# Активация ВО
RUN . env/bin/activate

# Получаем список необходимых компонентов
ADD conf/requirements.txt requirements.txt
# Установка необходимых компонентов в ВО
RUN pip3 install -r requirements.txt
# Создаем проект Django
RUN django-admin.py startproject CocktailManager

WORKDIR $project_name

RUN mkdir static
RUN mkdir media
# Получаем файл с настройками nginx
ADD conf/CocktailManager-nginx.conf conf/CocktailManager-nginx.conf
# Получение сертификата
ADD certificates/webhook_selfsigned_cert.key ssl/webhook_selfsigned_cert.key
ADD certificates/webhook_selfsigned_cert.pem ssl/webhook_selfsigned_cert.pem

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CoctailManager-nginx.conf, чтобы nginx увидел его
RUN ln -s conf/CocktailManager-nginx.conf /etc/nginx/sites-enabled/

# Добавление необходимых данных для uwsgi
ADD https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params uwsgi_params

# Переписываем setting.py проекта Django
COPY conf/settings.py CocktailManager/
# Собирает статические файлы в STATIC_ROOT
RUN /bin/sh -c "echo yes | python3 manage.py collectstatic"

WORKDIR /etc
RUN rm -f rc.local
ADD conf/rc.local /etc/rc.local

# Отключаем ВО
#RUN /bin/bash deactivate

# Устанавливаем uwsgi глобально
RUN pip3 install uwsgi

# Установка пользователя
USER www-data:www-data

# Запускаем наш сервер
#RUN service nginx restart
#ENTRYPOINT [“uwsgi --ini”]
#CMD [“CocktailManager/conf/CocktailManager.ini”]

EXPOSE 443
