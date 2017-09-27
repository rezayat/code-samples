from django.db import models


class Application(models.Model):

    VACANCIES = [
        ('developer', 'Software Developer'),
        ('designer', 'Graphic Designer'),
        ('devops', 'Devops'),
    ]

    STATES = [
        ('new', 'New'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
    ]

    created = models.DateField(auto_now_add=True)
    updated = models.DateField(auto_now=True)
    email = models.EmailField()
    cover = models.TextField()
    position = models.CharField(choices=VACANCIES, max_length=16)
    status = models.CharField(choices=STATES, max_length=16, default='new')
