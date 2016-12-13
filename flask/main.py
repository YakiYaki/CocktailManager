from flask import Flask, request
import telebot
import json

from config import Configuration
conf = Configuration()

# CONFIG
TOKEN    = conf.config_get('main', 'token')
HOST     = conf.config_get('main', 'host')
PORT     = int(conf.config_get('main', 'port'))
CERT     = '/app/ssl/webhook_selfsigned_cert.pem'
CERT_KEY = '/app/ssl/webhook_selfsigned_cert.key'

bot = telebot.TeleBot(TOKEN)
app = Flask(__name__)
context = (CERT, CERT_KEY)

@app.route('/')
def hello():
    return 'Hello World!'

@app.route('/bot/' + TOKEN, methods=['POST'])
def webhook():
    payload = json.loads(request.data.decode('utf-8'))
    chat_id = payload['message']['chat']['id']
    text = payload['message'].get('text')
    bot.send_message(chat_id, text)

    return 'OK'

if __name__ == '__main__':
    app.run(host='0.0.0.0',
            port=PORT,
            ssl_context=context,
            debug=True)