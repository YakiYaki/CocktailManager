## CocktailManager
Cocktail Manager - bot for Telegram. 

### Развертывание

Для развертывания необходимо:

1. Скопировать себе репозиторий. 
2. Перейти в директорию *Container*
3. Сгенерировать самоподписанный сертификат. (инструкция ниже)
4. Далее запустить контейнер:

    docker run

или собрать свой docker-образ командой:

    docker build -t <image_name> .


### Получение самоподписанного сертификата (self-signed certificate)

Сертификат необходим для настройки *WebHook*. 

Сначала устанавливаем `openssl`:

    sudo apt-get install openssl
    
Затем перейдем в любую директорию и сгенерируем приватный ключ:

    openssl genrsa -out webhook_pkey.pem 2048

В текущей директории должен появиться файл, название которого мы указываем после ключа `-out`. 

Генерируем самоподписанный сертификат:

    openssl req -new -x509 -days 3650 -key webhook_pkey.pem -out webhook_cert.pem

Создание (`-new`) self-signed сертификата (`-x509`) для использования в качестве сертификата сервера или сертификата CA. Сертификат создается с использованием секретного ключа `-key`. Создаваемый сертификат будет действителен в течение 3650 дней (`-days`).

После этой команды нам предложат ввести некоторую информацию о себе. Если не хотите ничего вводить, ставьте точку. Когда появится предложение ввести *Common Name*, следует написать *IP адрес сервера*, на котором будет запущен бот, в формате одного из ниже приведенного списка.

The Common Name may be one of the following:

1. A Fully Qualified Domain Name (e.g. "secure.yourdomain.com")
2. A Fully Qualified Domain Name with a wildcard (*) at the start of the domain name (e.g. *.yourdomain.com or *.secure.yourdomain.com).
3. An Internal Server Name (e.g. "intranetserver")
4. A Private IP address (e.g. "192.168.0.1")
5. A Public IP address (e.g. "202.144.8.10")

### Некоторые команды Docker

* Просмотр всех образов: `docker images`
* Просмотр всех контейнеров: `docker ps -a` или только их ID `docker ps -aq`
* Удалить все контейнеры: `docker rm $(docker ps -aq)`
* Удалить образ: `docker rmi IMAGE_ID`

