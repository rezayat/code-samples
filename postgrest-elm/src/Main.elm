module Main exposing (..)

import Commands exposing (Msg(..))
import Html
import Models exposing (Model)
import Update
import Views.View as View


main : Program (Maybe Model) Model Msg
main =
    Html.programWithFlags
        { init = Commands.init
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        , view = View.view
        }
