module Views.View exposing (view)

import Commands exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (Model)
import Views.Content
import Views.Footer
import Views.Header


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Views.Header.view model
        , Views.Content.view model
        , Views.Footer.view model
        ]
