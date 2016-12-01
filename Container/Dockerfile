# Основные настройки
FROM ubuntu:16.04

# Переменные
# Путь к репозиторию
ENV cocktail_rep https://raw.githubusercontent.com/YakiYaki/CocktailManager/master
# Имя директории контейнера, имя директории проекта (имя проекта Django), имя приложения Django
ENV container_name=CocktailBotHome project_name=CocktailManager app_name=manager


RUN [“mkdir”, “data”]
WORKDIR /data
RUN [“mkdir”, “$container_name”]
WORKDIR /data/$container_name

# Установка необходимых компонентов
RUN [“apt-get”, “update”]
RUN [“apt-get”, “install”, “-y”, “nginx”, “python3”, “python3.5-dev”, “python3-pip”, “python3-venv”, “git”]

# Получение сертификата
RUN [“mkdir”, “ssl”]
ADD certificates/webhook_selfsigned_cert.key ssl/webhook_selfsigned_cert.key
ADD certificates/webhook_selfsigned_cert.pem ssl/webhook_selfsigned_cert.pem

# Создание виртуального окружения (ВО)
RUN [“python3”, “-m”, “venv”, “env”]

# Активация ВО
RUN [“source”, “/env/bin/activate”]

# Получаем список необходимых компонентов
ADD ${cocktail_rep}/conf/requirements.txt requirements.txt
# Получаем файл с настройками nginx
ADD ${cocktail_rep}/conf/CocktailManager-nginx.conf requirements.txt

#Установка необходимых компонентов в ВО
RUN [“pip3”, “install”, “-r”, “requirements.txt”]
RUN [“rm”, “rc.local”]
ADD ${cocktail_rep}/conf/rc.local /etc/rc.local

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
CMD [“CocktailManager/conf/CocktailManager.ini”]

EXPOSE 443
