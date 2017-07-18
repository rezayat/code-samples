FROM python:alpine

COPY . /application
WORKDIR /application

RUN pip install -r requirements.txt

#ENTRYPOINT ["python"]
CMD ["python", "application.py"]
