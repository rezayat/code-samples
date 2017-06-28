# from django.shortcuts import render
from django.http import JsonResponse
from .models import User
from django.forms.models import model_to_dict
from django.views.generic import View
import json


class UserView(View):
    """docstring for UserView"""

    def get(self, request, *args, **kwargs):
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
            raise e
        else:
            pass
        finally:
            pass

        return JsonResponse(data)

    def post(self, request, *args, **kwargs):
        posted_data = request.body.decode('utf-8')
        dict_obj = json.loads(posted_data)
        existing_user = User.objects.filter(email=dict_obj['email'])

        if existing_user:
            data = {
                'status': 'fail',
                'message': '{email} already exists'.format(
                    email=dict_obj['email']),
            }
            return JsonResponse(data)

        try:
            user = User(**dict_obj)
            user.save()
            data = {
                'status': 'success',
                'message': '{email} added successfully !'.format(
                    email=dict_obj['email']),
            }

            return JsonResponse(data)

        except Exception as e:
            raise e
        else:
            pass
        finally:
            pass

        data = {
            'status': 'fail',
            'message': 'could not add {email}'.format(
                email=dict_obj['email']),
        }

        return JsonResponse(data)
