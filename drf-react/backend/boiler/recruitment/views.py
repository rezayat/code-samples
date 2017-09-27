from rest_framework import viewsets

from . import models
from . import serializers


class ApplicationViewSet(viewsets.ModelViewSet):
    queryset = models.Application.objects.all().order_by('-created')
    serializer_class = serializers.ApplicationSerializer
