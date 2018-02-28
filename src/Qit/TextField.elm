module Qit.TextField exposing (Message, State, update, view)

{-| TextField
@docs Message, State, update, view
-}

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input

import Qit.Style exposing (Style(..))

type Message id = Focus id | Blur id

type alias State id = Maybe id

update : State id -> Message id -> State id
update state message =
    case message of
        Focus id -> Just id
        Blur id -> if state == Just id then Nothing else state

view : (Message id -> msg) -> (Style -> style) -> State id -> id -> String -> String -> (String -> msg) -> Element style variation msg
view lift style state id label value message =
    let focussed = state == Just id
 
        textOptions = [ onFocus <| lift <| Focus id
                      , onBlur <| lift <| Blur id
                      ]

        labelStyle = if focussed then style FocussedLabel else if value == "" then style Label else style FloatingLabel
        labelOptions = height (px 16) :: inlineStyle [("z-index", "1"), ("pointer-events","none")] :: (if focussed || value /= "" then [] else [moveDown 20])

    in el (style None) [height (px 45)] (
        Input.text (style TextInput) textOptions
            { onChange = message
            , value = value
            , label = Input.labelAbove <| el labelStyle labelOptions (text label)
            , options = []
        })
