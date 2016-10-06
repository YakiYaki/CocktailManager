sudo apt-add-repository ppa:pitti/postgresql
sudo apt-get update
sudo apt-get install postgresql-9.2
# Настройка базы данных для удалённого подключения (возможно, потребуется переписать скрипт под конкретный сервер)
cat "listen_addresses ='localhost,192.168.0.1'">> /etc/postgresql/9.2/main/postgresql.conf
cat "host    all    all    192.168.0.1/16    md5">> /etc/postgresql/9.2/main/pg_hba.conf
sudo service postgresql restart
# Прописываем конфигурации, чтобы не писать каждый раз всё. Подключение: psql 'service=connect'
cat "
[connect]
dbname=CocktailManager
host=НАШ ХОСТ!!!!!!!!!!
port=НАШ ПОРТ!!!!!!!!!!
user=postgres">> /etc/postgresql/9.2/main/.pg_service.conf
