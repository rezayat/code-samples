# requires httpie library: pip install httpie

HOST=172.16.149.136
JWT=$(http -b POST $HOST/login username=rawad pass=1234 | jq '.[0].token' | sed -e 's/^"//' -e 's/"$//')

# login and get jwt token
# http POST $HOST/login username=rawad pass=1234

# user jwt to access api
http ${HOST}/api/invoice "Authorization: Bearer ${JWT}"

# user jwt to access api (using jwt plugin)
http --auth-type=jwt --auth=${JWT} ${HOST}/api/invoice

# user posts to invoice
http POST ${HOST}/api/invoice "Authorization: Bearer ${JWT}" \
    amount=10000     \
    dummy=new_record \
    type=in          \
    salesman=imad

# user posts to invoice (using jwt plugin)
http --auth-type=jwt --auth=${JWT} POST ${HOST}/api/invoice \
    amount=11000     \
    dummy=new_record \
    type=in          \
    salesman=imad
