module Update exposing (update)

import Commands exposing (..)
import Config exposing (..)
import Models exposing (Model)


-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickLogIn ->
            ( model, loginUserCmd model loginUrl )

        GetTokenCompleted result ->
            getTokenCompleted model result

        GetInvoice ->
            ( model, getInvoiceCmd model )

        GetInvoiceCompleted result ->
            getInvoiceCompleted model result
