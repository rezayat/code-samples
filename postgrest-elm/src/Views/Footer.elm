module Views.Footer exposing (view)

import Commands exposing (Msg(..))
import Html exposing (..)
import Models exposing (Model)


view : Model -> Html Msg
view model =
    blockquote []
        [ pre [] [ text model.invoice ]
        ]
