from django.shortcuts import render
from django.http import HttpResponse
from django.views.generic.base import TemplateView

from config import Configuration
import json
import logging
import telebot

conf = Configuration()
token = str(conf.config_get('main', 'token'))

Bot = telebot.TeleBot(token)

logger = logging.getLogger(__name__)

# Create your views here.

# index for site
class IndexView(TemplateView):
	template_name = "index.html"

	def get_context_data(self, **kwargs):
		context = super(IndexView, self).get_context_data(**kwargs)
		return context

# bot body
class BotView(TemplateView):
	def post(self, request, in_token):
		if in_token != token:
			return HttpResponseForbidden('Invalid token!')

		raw = request.body.decode('utf-8')
		logger.info(raw)

		try:
			payload = json.loads(raw)
		except ValueError:
			return HttpResponseBadRequest('Invalid request body')
		else:
			chat_id = payload['message']['chat']['id']
			text = payload['message'].get('text')
			Bot.sendMessage(chat_id, text)

		return JsonResponse({}, status=200)
