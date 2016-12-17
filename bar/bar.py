from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
import telebot
import json
import logging


from config import Configuration
conf = Configuration()

# CONFIG
TOKEN = conf.config_get('main', 'token')
DB_NAME = conf.config_get('db', 'name')
DB_USER = conf.config_get('db', 'user')
DB_PASS = conf.config_get('db', 'pass')

class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'ADAFRUIT'

class ProductionConfig(Config):
    DEBUG = False

# "postgresql://" + DB_USER + ":" + DB_PASS + "@localhost/" + DB_NAME

bot = telebot.TeleBot(TOKEN)
app = Flask(__name__)
app.config.from_object(ProductionConfig)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://" + DB_USER + ":" + DB_PASS + "@localhost/" + DB_NAME
db = SQLAlchemy(app)

logger = logging.getLogger('bot.log')
logger.setLevel(logging.DEBUG)

#context = (CERT, CERT_KEY)

from models import Cocktail

@app.route('/')
def hello():
    return 'Hello World!'

@app.route('/bot/' + TOKEN, methods=['POST'])
def webhook():
    payload = json.loads(request.data.decode('utf-8'))
    chat_id = payload['message']['chat']['id']
    text = payload['message'].get('text')

    logger.debug(text)

    if text == "/start":
        bot.send_message(chat_id, "Hello! I'm a Cocktail Manager.\nCheck out this commands:\n/list")
    elif text == "/list":
        cocktails = db.session.query(Cocktail).all()
        ans = ""
        for c in cocktails:
            ans += str(c.id) + ". " + c.name + "\n"
        if ans != "":
            bot.send_message(chat_id, ans)
        else:
            bot.send_message(chat_id, "Sorry, there are no cocktails in my memory yet!")
    elif text != "":
        bot.send_message(chat_id, text)
    else:
        bot.send_message(chat_id, "There is no text, dude :)")

    return 'OK'

if __name__ == '__main__':
    app.run(host='0.0.0.0')