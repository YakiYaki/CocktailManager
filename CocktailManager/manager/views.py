from django.shortcuts import render
from django.http import HttpResponseForbidden, HttpResponseBadRequest, JsonResponse
from django.views.generic.base import TemplateView
from django.views.generic import View
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

from config import Configuration
import json
import logging
import telebot

conf = Configuration()
token = str(conf.config_get('main', 'token'))

Bot = telebot.TeleBot(token)

logger = logging.getLogger('manager.log')

# Create your views here.

# index for site
class IndexView(TemplateView):
	template_name = "index.html"

	def get_context_data(self, **kwargs):
		context = super(IndexView, self).get_context_data(**kwargs)
		return context

# bot body
class BotView(View):
	def post(self, request):
		
		logger.info("HEREEEEEEEEEEEEEEEEEEEEE!")

		#if in_token != token:
		#	logger.error("Invalid token!")
		#	return HttpResponseForbidden('Invalid token!')

		raw = request.body.decode('utf-8')
		logger.info(raw)

		try:
			payload = json.loads(raw)
		except ValueError:
			logger.info("Invalid request body!")
			return HttpResponseBadRequest('Invalid request body')
		else:
			chat_id = payload['message']['chat']['id']
			text = payload['message'].get('text')
			Bot.sendMessage(chat_id, text)

		return JsonResponse({}, status=200)

	@method_decorator(csrf_exempt)
	def dispatch(self, request, *args, **kwargs):
		return super(BotView, self).dispatch(request, *args, **kwargs)
