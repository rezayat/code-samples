FROM python:3.6.1

COPY . /application
WORKDIR /application

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]
CMD ["application.py"]
