FROM python:alpine

COPY . /application
WORKDIR /application

RUN pip install -r requirements.txt

CMD ["python", "application.py"]
