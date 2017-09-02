port module Commands exposing (..)

import Config exposing (..)
import Debug
import Http exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Models exposing (Model)


-- Messages


type Msg
    = ClickLogIn
    | GetTokenCompleted (Result Http.Error String)
    | GetInvoice
    | GetInvoiceCompleted (Result Http.Error String)


init : Maybe Model -> ( Model, Cmd Msg )
init model =
    case model of
        Just model ->
            ( model, Cmd.none )

        Nothing ->
            ( Model "rawad" "1234" "" "" "", Cmd.none )



-- Encode user to construct POST request body (for Register and Log In)


userEncoder : Model -> Encode.Value
userEncoder model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "pass", Encode.string model.password )
        ]



-- Decode POST response to get access token


tokenDecoder : Decoder String
tokenDecoder =
    (Decode.index 0 << Decode.field "token") Decode.string



-- POST login request


loginUser : Model -> String -> Http.Request String
loginUser model apiUrl =
    let
        body =
            model
                |> userEncoder
                |> Http.jsonBody

        dummy =
            Debug.log "json" body
    in
    Http.post apiUrl body tokenDecoder


loginUserCmd : Model -> String -> Cmd Msg
loginUserCmd model apiUrl =
    Http.send GetTokenCompleted (loginUser model apiUrl)


getTokenCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg )
getTokenCompleted model result =
    case result of
        Ok newToken ->
            let
                dummy =
                    Debug.log "token:" newToken
            in
            setStorageHelper { model | token = newToken, password = "", errorMsg = "" }

        Err error ->
            let
                myError =
                    Debug.log "error:" (toString error)
            in
            ( { model | errorMsg = toString error }, Cmd.none )



-- GET request for invoice (authenticated)


getInvoice : Model -> Http.Request String
getInvoice model =
    { method = "GET"
    , headers = [ Http.header "Authorization" ("Bearer " ++ model.token) ]
    , url = invoiceUrl
    , body = Http.emptyBody
    , expect = Http.expectString
    , timeout = Nothing
    , withCredentials = False
    }
        |> Http.request


getInvoiceCmd : Model -> Cmd Msg
getInvoiceCmd model =
    Http.send GetInvoiceCompleted (getInvoice model)


getInvoiceCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg )
getInvoiceCompleted model result =
    case result of
        Ok newInvoice ->
            setStorageHelper { model | invoice = newInvoice }

        Err _ ->
            ( model, Cmd.none )



-- Helper to update model and set localStorage with the updated model


setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
    ( model, setStorage model )



-- Ports


port setStorage : Model -> Cmd msg


port removeStorage : Model -> Cmd msg
