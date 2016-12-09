from django.conf.urls import url
from manager.views import IndexView, BotView

urlpatterns = [
	url(r'^$', IndexView.as_view(), name="index"),
	url(r'^bot/(?P<bot_token>.+)/$', BotView.as_view(), name="bot"),
]


