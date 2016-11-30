## CocktailManager
Cocktail Manager - bot for Telegram. 

Для развертывания необходимо запустить Dockerfile.

### Получение самоподписанного сертификата (self-signed certificate)

Сертификат необходим для настройки *WebHook*. 

Сначала устанавливаем `openssl`:
`sudo apt-get install openssl`
Затем перейдем в любую директорию и сгенерируем приватный ключ:
`openssl genrsa -out webhook_pkey.pem 2048`
В текущей директории должен появиться файл, название которого мы указываем после ключа `-out`. 
Генерируем самоподписанный сертификат:
`openssl req -new -x509 -days 3650 -key webhook_pkey.pem -out webhook_cert.pem`


