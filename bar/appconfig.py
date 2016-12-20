from config import Configuration
conf = Configuration()

TOKEN = conf.config_get('main', 'token')
DB_NAME = conf.config_get('db', 'name')
DB_USER = conf.config_get('db', 'user')
DB_PASS = conf.config_get('db', 'pass')

class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = conf.config_get('main', 'key')
    SQLALCHEMY_DATABASE_URI = "postgresql://" + DB_USER + ":" + DB_PASS + "@localhost/" + DB_NAME

class ProductionConfig(Config):
    DEBUG = False

class DebugConfig(Config):
	DEBUG = True