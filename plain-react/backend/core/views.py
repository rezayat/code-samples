import json

from django.http import JsonResponse
from django.forms.models import model_to_dict
from django.views.decorators.csrf import csrf_exempt

from .models import User


@csrf_exempt
def user(request, pk):
    data = {
        'users': [],
        'result': 'fail'
    }

    existing_user = User.objects.filter(id=pk).first()
    if existing_user:
        users = [model_to_dict(existing_user)]
        data['users'] = users
        data['result'] = 'success'

    return JsonResponse(data)


@csrf_exempt
def users(request):
    if request.method == 'GET':
        data = {
            'users': [],
            'result': 'fail'
        }

        users = User.objects.all()
        users = [model_to_dict(d) for d in users]
        data['users'] = users
        data['result'] = 'success'
        return JsonResponse(data)

    else:
        posted_data = json.loads(request.body.decode('utf-8'))

        existing_user = User.objects.filter(email=posted_data['email'])

        if existing_user:
            data = {
                'status': 'fail',
                'message': '{email} already exists'.format(
                    email=posted_data['email']),
            }
            return JsonResponse(data)

        User.objects.create(**posted_data)

        data = {
            'status': 'success',
            'message': '{email} added successfully !'.format(
                email=posted_data['email']),
        }

        return JsonResponse(data)
