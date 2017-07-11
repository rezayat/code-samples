## works
curl -i -d '{"username":"rawad", "password":"54321"}' "localhost:1234/app/login"
curl -i -d '{"username":"admin", "password":"12345"}' "localhost:1234/app/login"

## do not work
curl -i -d '{"username":"admin", "password":"incorrect pass"}' "localhost:1234/app/login"
curl -i -d '{"username":"missing json"}' "localhost:1234/app/login"

