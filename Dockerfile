FROM python:3.6.1

# set working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# add requirements (to leverage Docker cache)
ADD ./requirements.txt /usr/src/app/requirements.txt
# ADD ./entrypoint.sh /usr/src/app/entrypoint.sh
# RUN chmod +x /usr/src/app/entrypoint.sh

# install requirements
RUN pip install -r requirements.txt
RUN pip list

# add app
ADD . /usr/src/app
WORKDIR /usr/src/app/django_react


# RUN echo ls
# RUN python manage.py migrate
# RUN . /usr/src/app/entrypoint.sh

# run server
# CMD python ./django_react/manage.py runserver -h 0.0.0.0
# CMD ["python","./django_react/manage.py","migrate"]

