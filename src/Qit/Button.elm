module Qit.Button exposing (flat)

{-| Button
@docs flat
-}

import Element exposing (..)
import Element.Attributes exposing (..)

import Qit.Style exposing (Style(..))

{-| Placeholder
-}
flat: (Style -> style) -> String -> List (Attribute variation msg) -> Element style variation msg
flat style caption attributes =
    button (style FlatButton) (height (px 36) :: minWidth (px 88) :: paddingXY 8 0 :: attributes) (text caption)
