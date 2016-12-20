from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from appconfig import ProductionConfig, DebugConfig, TOKEN
import telebot
import socket

app = Flask(__name__)

if socket.gethostname() == 'linux-yaki':
	app.config.from_object(DebugConfig)
else:
	app.config.from_object(ProductionConfig)

db = SQLAlchemy(app)
bot = telebot.TeleBot(TOKEN)

import views

