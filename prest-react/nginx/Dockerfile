FROM nginx:1.13.0

# ENV web-service=0.0.0.0:5000
# ENV web-service=0.0.0.0:3000/api

RUN rm /etc/nginx/conf.d/default.conf
ADD /nginx.conf /etc/nginx/conf.d
