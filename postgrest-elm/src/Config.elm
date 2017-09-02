module Config exposing (..)


api : String
api =
    "http://172.16.149.136"


loginUrl : String
loginUrl =
    api ++ "/login"


invoiceUrl : String
invoiceUrl =
    api ++ "/api/invoice"
