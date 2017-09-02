module Views.Content exposing (view)

import Commands exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Models exposing (Model)


view : Model -> Html Msg
view model =
    p [ class "text-center" ]
        [ button [ class "btn", onClick ClickLogIn ] [ text "Login" ]
        , div [] [ text " | " ]
        , button [ class "btn", onClick GetInvoice ] [ text "Invoice" ]
        ]
