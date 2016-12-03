## CocktailManager
Cocktail Manager - bot for Telegram. 

### Возможности бота

    ...

### Запуск из Telegram

    ...

### Запуск сервера

# Установка Docker

* Debian: https://docs.docker.com/engine/installation/linux/debian/
* Ubuntu: http://cyber01.ru/manuals/ustanovka-i-ispolzovanie-docker-v-ubuntu-15-04/

После установки Dokcer создаём и запускаем контейнер из образа:

   *docker run -itp [-d] **Iport**:**Oport** *image_id
   
   **Iport** - порт, который разрешён в Dockerfile и с которого будет пробрасываться трафик на вашей машине
   **Oport** - порт, который будет открыт внутри контейнера, на котором будет слушать наше приложение
   image_id - id образа, контейнер с которого мы создаём
   
Флаги:
   -i - интерактивный режим, связывающий вашу консоль с контейнером
   -t - разрешить tty
   -d - опциональный, запускает контейнер в качестве демона

### Сборка (для разработчиков)

# Установка Docker

* Debian: https://docs.docker.com/engine/installation/linux/debian/
* Ubuntu: http://cyber01.ru/manuals/ustanovka-i-ispolzovanie-docker-v-ubuntu-15-04/

После установки Dokcer собираем образ:

1. Скопировать себе репозиторий. git clone https://github.com/YakiYaki/CocktailManager.git
2. Перейти в директорию *Container/*
3. Собрать docker-образ командой:

    docker build -t image_name .

# Настройка самоподписанного сертификата (self-signed certificate)

В директории *Container/* открываете файл *ssl.ini*

Пишете информацию о своей компании в этот файл (оставляете пустую строку для значения по умолчанию)
Заполняете файл в формате (в *[]* значение по умолчанию):

Country Name (2 letter code) [AU]: *RU*
State or Province Name (full name) [Some-State]: *Russian Federation*
Locality Name (eg, city) []: *Moscow*
Organization Name (eg, company) [Internet Widgits Pty Ltd]: *Cocktail Manager Inc.*
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []: *student.bmstu.cloud:10264*
Email Address []: *N02@yandex.ru*

# Настройки приложения uwsgi

Смотреть в файле *conf/CocktailManager.ini*

# Настройки автозагрузки

Смотреть в файле *conf/rc.local*
Если хотите убрать приложение из автозагрузки, просто очистите этот файл

# Настройки nginx

Смотреть в файле *conf/CocktailManager-nginx.conf*
Важно сменить значение в найстройке server_name на IP-адрес вашего сервера

# Настройки Django

Смотреть в файле *conf/settings.py*

# Необходимые пакеты для создания окружения

Смотреть в файле *conf/requirements.txt*

# Некоторые команды Docker

* Просмотр информации: `docker info`
* Просмотр всех образов: `docker images`
* Просмотр всех контейнеров: `docker ps -a` или только их ID `docker ps -aq`
* Удалить все контейнеры: `docker rm $(docker ps -aq)`
* Удалить образ: `docker rmi IMAGE_ID`
* Удалить все образы: `docker rmi $(docker images -q)`

# Ставим WebHook


*curl -F "url=https://your_domain.com/where-the-script-will-be/bot-script.py" -F "certificate=@/location/of/cert/webhook_selfsigned_cert.pem" https://api.telegram.org/bot**BOT_TOKEN**/setWebhook*

**BOT TOKEN** - токен, полученный вашим ботом от Bot Father

The final URL is simply calling the setWebhook method on your bot token. That should be your webhook set up. You wont be able to call the getUpdates method anymore, as the webhook will block it.
