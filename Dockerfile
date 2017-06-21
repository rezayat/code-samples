FROM python:3.6.1

# set working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# add requirements (to leverage Docker cache)
ADD ./requirements.txt /usr/src/app/requirements.txt

# install requirements
RUN pip install -r requirements.txt
RUN pip list

# add app
ADD . /usr/src/app
WORKDIR /usr/src/app/django_react

# run server

# CMD python ./django_react/manage.py runserver -h 0.0.0.0
