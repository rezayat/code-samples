from django.db import models
# from django.contrib import admin
# import datetime
from django.utils import timezone
# from django.utils.formats import date_format
# import recruitment.settings as settings
# from django.urls import reverse


class User(models.Model):

    class Meta:
        db_table = 'users'
        default_permissions = ('add', 'view', 'delete', 'change')

    username = models.CharField(max_length=200, verbose_name='User Name')
    email = models.EmailField()
    active = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return self.username

    # def get_created(self):
    #     return date_format(
    #         timezone.localtime(self.created_at),
    #         'DATETIME_FORMAT'
    #     )

    # def get_absolute_url(self):
    #     return reverse('core:success', args=[str(self.pk)])
