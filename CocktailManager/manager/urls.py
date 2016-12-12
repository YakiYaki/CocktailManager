from django.conf.urls import url
from manager.views import IndexView, BotView

urlpatterns = [
	url(r'^$', IndexView.as_view(), name="index"),
	#url(r'^bot/(?P<in_token>.+)/$', BotView.as_view(), name="bot"),
	url(r'^bot/hh/$', BotView.as_view(), name="bot"),
]


