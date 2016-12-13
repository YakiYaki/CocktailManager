from flask import Flask, request
from config import Configuration
conf = Configuration()

import telegram

# CONFIG
TOKEN    = conf.config_get('main', 'token')
HOST     = conf.config_get('main', 'host') # Same FQDN used when generating SSL Cert
PORT     = conf.config_get('main', 'port')
CERT     = '/app/ssl/webhook_selfsigned_cert.pem'
CERT_KEY = '/app/ssl/webhook_selfsigned_cert.key'

bot = telegram.Bot(TOKEN)
app = Flask(__name__)
context = (CERT, CERT_KEY)

@app.route('/')
def hello():
    return 'Hello World!'

@app.route('/bot/' + TOKEN, methods=['POST'])
def webhook():
    update = telegram.update.Update.de_json(request.get_json(force=True))
    bot.sendMessage(chat_id=update.message.chat_id, text='Hello, there')

    return 'OK'


#def setWebhook():
    #bot.setWebhook(webhook_url='https://%s:%s/%s' % (HOST, PORT, TOKEN),
    #               certificate=open(CERT, 'rb'))

if __name__ == '__main__':
#    setWebhook()

    app.run(host='0.0.0.0',
            port=PORT,
            ssl_context=context,
            debug=True)