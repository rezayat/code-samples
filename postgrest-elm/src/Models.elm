module Models exposing (..)

{-
   MODEL
   * Model type
-}


type alias Model =
    { username : String
    , password : String
    , token : String
    , invoice : String
    , errorMsg : String
    }
