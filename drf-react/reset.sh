export DJANGO_SECRET_KEY='your-secret-key'
rm db.sqlite3
rm api/migrations/00*
rm assets/bundles/*.js
./manage.py makemigrations
./manage.py migrate
./manage.py loaddata api/fixtures/books.json
./node_modules/.bin/webpack --config webpack.config.js
python3 manage.py runserver
