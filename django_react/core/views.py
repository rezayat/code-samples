# from django.shortcuts import render
from django.http import JsonResponse
from .models import User
from django.forms.models import model_to_dict
# from django.views.generic import View
import json

from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def user(request, pk=0, *args, **kwargs):
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
def users(request, *args, **kwargs):
    if request.method == 'GET':
        data = {
            'users': [],
            'result': 'fail'
        }
        try:
            users = User.objects.all()
            users = [model_to_dict(d) for d in users]
            data['users'] = users
            data['result'] = 'success'

        except Exception as e:
            return JsonResponse(data)
        else:
            pass
        finally:
            pass

        return JsonResponse(data)

    else:

        posted_data = request.body.decode('utf-8')
        dict_obj = json.loads(posted_data)
        # dict_obj = posted_data

        existing_user = User.objects.filter(email=dict_obj['email'])

        if existing_user:
            data = {
                'status': 'fail',
                'message': '{email} already exists'.format(
                    email=dict_obj['email']),
            }
            return JsonResponse(data)

        user = User(**dict_obj)
        user.save()
        data = {
            'status': 'success',
            'message': '{email} added successfully !'.format(
                email=dict_obj['email']),
        }

        return JsonResponse(data)

        data = {
            'status': 'fail',
            'message': 'could not add {email}'.format(
                email=dict_obj['email']),
        }

        return JsonResponse(data)
