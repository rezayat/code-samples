from django.conf.urls import url
# from django.urls import reverse

# from django.contrib import auth
# from django.contrib.auth import views as auth_views
# from django.contrib.auth.decorators import login_required, user_passes_test
# from django.contrib.auth.models import User

from . import views

# class based
# urlpatterns = [
#     url(r'', views.UserView.as_view(), name='users'),
#     url(r'(?P<pk>\d+)', views.UserView.as_view(), name='update'),
# ]

urlpatterns = [
    url(r'^$', views.get_all_users, name='users'),
    url(r'^$', views.add_user, name='add_user'),
    url(r'^(?P<pk>\d+)$', views.get_user, name='user'),
]
