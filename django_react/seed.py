import os

os.environ['DJANGO_SETTINGS_MODULE'] = 'django_react.settings'

import django

django.setup()

from core.models import User


User.objects.create(username='omar', email='omar.aboumrad@gmail.com')
User.objects.create(username='rawad', email='rawdaw@mlmasd.com')
