module Views.Header exposing (view)

import Commands exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (Model)


view : Model -> Html Msg
view model =
    h2 [ class "text-center" ] [ text "JWT Demo" ]
