from django.conf.urls import url, include
from django.contrib import admin

from rest_framework import routers

from recruitment import views


router = routers.DefaultRouter()
router.register(r'applications', views.ApplicationViewSet)

urlpatterns = [
    url(r'^api/', include(router.urls)),
    url(r'^admin/', admin.site.urls),
]
