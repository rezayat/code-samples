from django.conf.urls import url

from . import views


urlpatterns = [
    url(r'^$', views.users, name='users'),
    url(r'^$', views.users, name='add_user'),
    url(r'^(?P<pk>\d+)$', views.user, name='user'),
]
