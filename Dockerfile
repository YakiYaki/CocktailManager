#Основные настройки
FROM ubuntu:16.04

WORKDIR /usr/local
RUN [“mkdir”, “CocktailBotHome”]
WORKDIR /usr/local/CocktailBotHome

# Установка необходимых компонентов
RUN [“apt-get”, “update”]
RUN [“apt-get”, “install”, “-y”, “nginx”, “python3”, “python3.5-dev”, “python3-pip”, “python3-venv”, “git”]

# Получение сертификата
RUN [“mkdir”, “/etc/nginx/ssl”]
ADD https://raw.githubusercontent.com/YakiYaki/CocktailManager/master/sertificates/nginx-selfsigned.key /etc/ssl/nginx-selfsigned.key
ADD https://raw.githubusercontent.com/YakiYaki/CocktailManager/master/sertificates/nginx-selfsigned.crt /etc/ssl/nginx-selfsigned.crt

# Создание виртуального окружения (ВО)
RUN [“python3”, “-m”, “venv”, “env”]

# Активация ВО
RUN [“source”, “/env/bin/activate”]

# Получаем список необходимых компонентов
ADD https://raw.githubusercontent.com/YakiYaki/CocktailManager/master/conf/requirements.txt requirements.txt
# Получаем файл с настройками nginx
ADD https://raw.githubusercontent.com/YakiYaki/CocktailManager/master/conf/CocktailManager-nginx.conf requirements.txt

#Установка необходимых компонентов в ВО
RUN [“pip3”, “install”, “-r”, “requirements.txt”]
RUN [“rm”, “rc.local”]
ADD https://raw.githubusercontent.com/YakiYaki/CocktailManager/master/conf/rc.local /etc/rc.local

# В папке /etc/nginx/sites-enabled создаем ссылку на файл CoctailManager-nginx.conf, чтобы nginx увидел его
RUN [“ln”, “-s”, “CocktailManager-nginx.conf”, “/etc/nginx/sites-enabled/”]


# Разворачивание проекта
# Установка пользователя
USER www-data:www-data

# Создаем проект Django
RUN [“django-admin.py”, “startproject”, “CocktailManager”]
# Дополняем проект нужными файлами
RUN [“git”, “clone”, “https://github.com/YakiYaki/CocktailManager.git”]

# Переписываем setting.py проекта Django
RUN [“cp”, “CoctailManager/conf/settings.py”, “CoctailManager/CocktailManager/”]

# Добавление необходимых данных для uwsgi
ADD https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params uwsgi_params
# Собирает статические файлы в STATIC_ROOT
RUN [“python3”, “CocktailManager/manage.py”, “collectstatic”]


# Отключаем ВО
RUN [“deactivate”]


# Устанавливаем uwsgi глобально
RUN [“pip3”, “install”, “uwsgi”]


# Запускаем наш сервер
RUN [“service”, “nginx”, “restart”]
ENTRYPOINT [“uwsgi --ini”]
CMD [“CoctailManager/conf/CocktailManager.ini”]

EXPOSE 443
