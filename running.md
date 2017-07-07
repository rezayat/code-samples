# running services locally (without docker)

## nginx 

sudo nginx -s stop
sudo nginx -c ~/projects/prest-react/nginx.conf

### project 

* site   : http://localhost:1234/
* api    : http://localhost:1234/api/
* users  : http://localhost:1234/api/users_dev/public/users

## prest go
export GOPATH=~/projects/prest-react/backend/prest/

cd ~/projects/prest-react/backend/prest/src/github.com/nuveo
go install


## prest run

export PREST_DEBUG=true
export PREST_CONF=~/projects/prest-react/backend/prest/bin/config.toml

cd ~/projects/prest-react/backend/prest/bin/
./prest

## react (frontend)

cd ~/projects/prest-react/frontend/
<!-- export REACT_APP_USERS_SERVICE_URL=http://localhost:3000/users_dev/public -->
export REACT_APP_USERS_SERVICE_URL=http://localhost:1234/api/users_dev/public

npm run build
serve -s build
