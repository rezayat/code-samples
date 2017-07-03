from django.db import models
from django.utils import timezone


class User(models.Model):

    username = models.CharField(max_length=200, verbose_name='User Name')
    email = models.EmailField()
    active = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = 'users'
        default_permissions = ('add', 'view', 'delete', 'change')

    def __str__(self):
        return self.username
