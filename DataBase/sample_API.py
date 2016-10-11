import psycopg2
import logging

conn=0
cur=0

def __log_init__():
	logging.basicConfig(level=logging.INFO, format='((arctime)) (levelname): (message)', filename='./log', filemod='w')
	logging.info("It's works!");

# Функция подключения к БД
def connect(dbname=CocktailManager, user=postgres, password=qwerty12345):
	conn = psycopg2.connect("dbname=%s, user=%s, password=%s", (dbname, user, password))  # Создаём подключение
	cur = conn.cursor()  # Создаём курсор для выполнения операций с БД

# Функция загрузки SQL скрипта
def loadScript(filename):
	query=""
	sql=open(filename, 'rt')
	line=sql.readline()
	while len(line)>0:
		query+=line
		line=sql.readline()
	return query

# Функция, печатающая все БД
def ShowDBs():
	cur.execute("SHOW DATABASES;")
	for row in cur:
		print(row)

# Функция, возвращающая список таблиц
def getTables():	
	cur.execute("SHOW TABLES;")
	return cur.fetchone()

# Функция, печатающая все таблицы
def ShowTables():
	for row in getTables():
		print(row)

# Функция, печатающая таблицу table
def ShowTable(table):
	for row in getAll(table):
		print(row)

# Выполняем команды для БД
def go(script):
	cur.execute(script)
	conn.commit()  # Сохраняем изменения, сделанные в таблице

# Получаем список строк таблицы
def getAll(table):
	cur.execute("SELECT * FROM %s;", (table))
	return cur.fetchone()

# Закрыть подключение к БД
def disconnect():
	cur.close()
	conn.close()

__log_init__()

if __name__ == "__main__":
	connect()
	go(loadScript("CoctailManager_create.sql"))
	ShowDBs()
	ShowTables()
	for t in getTables():
		ShowTable(t)
	disconnect()
	logging.info("Database success installed")
