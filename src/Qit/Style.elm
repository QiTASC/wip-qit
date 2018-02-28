module Qit.Style exposing (Style(..), default)

{-| Style
@docs Style, default
-}

import Color exposing (..)

import Style as S
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transition as Transition

{-| Placeholder
-}
type Style = None 
           | Body
           | Label | FocussedLabel | FloatingLabel 
           | TextInput | FocussedTextInput 
           | DatePicker | DatePickerYearHeader | DatePickerDateHeader | DatePickerMonthSelection | DatePickerContainer | DatePickerSelectedContent | DatePickerContent | DisabledFlatButton
           | Select | SelectArrow | SelectOption | SelectedOption
           | TitleBar | NavIcon
           | CellHeader | CellData | SelectedCellData
           | FlatButton

primaryColor = rgba 247 148 30 1

{-| Placeholder
-}
default : (Style -> style) -> List (S.Style style variation)
default style =
    [ S.style (style None) []
    , S.style (style TitleBar)
        [ Color.background primaryColor
        , Color.text (rgba 255 255 255 0.82)
        , Font.typeface [Font.font "Avenir"]
        , Font.size 24
        , Color.border (rgba 0 0 0 0.16)
        , Border.bottom 1
        ]
    , S.style (style FlatButton)
        [ Color.text (primaryColor)
        , Color.background (rgba 255 255 255 0)
        , Font.typeface [Font.font "Avenir"]
        , Border.rounded 2
        , S.prop "margin" "8px"
        , S.prop "overflow" "hidden"
        , S.prop "transform" "translate3d(0,0,0)"
        , S.hover
            [ Color.background (rgba 247 148 30 0.12)
            ]
        , S.focus
            [ Color.background (rgba 247 148 30 0.12)
            ]
        , S.pseudo "active"
            [ Color.background (rgba 247 148 30 0.40)
            ]
        , S.pseudo ":after"
            [ S.prop "content" "\" \""
            , S.prop "display" "block"
            , S.prop "position" "absolute"
            , S.prop "top" "0"
            , S.prop "left" "0"
            , S.prop "width" "100%"
            , S.prop "height" "100%"
            , S.prop "pointer-events" "none"
            , S.prop "background-image" "radial-gradient(circle, #000 50%, transparent 50.01%)"
            , S.prop "background-repeat" "no-repeat"
            , S.prop "background-position" "50%"
            , S.prop "transform" "scale(2, 2)"
            , S.prop "opacity" "0"
            , S.prop "transition" "transform .5s, opacity 1s"
            ]
        , S.pseudo "active:after"
            [ S.prop "transform" "scale(0,0)"
            , S.prop "opacity" ".12"
            , S.prop "transition" "0s"
            ]
        ]
    , S.style (style CellHeader)
        [ Color.border (rgba 0 0 0 0.16)
        , Color.background (rgba 0 0 0 0.08)
        , Color.text (rgba 0 0 0 0.87)
        , Border.bottom 1
        , Border.right 1
        , Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Font.lineHeight 2
        , Font.bold
        , Font.center
        ]
    , S.style (style CellData)
        [ Color.border (rgba 0 0 0 0.16)
        , Color.text (rgba 0 0 0 0.87)
        , Border.bottom 1
        , Border.right 1
        , Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Font.lineHeight 2
        , Font.alignRight
        ]
    , S.style (style SelectedCellData)
        [ Color.background (rgba 198 219 227 0.48)
        , Color.border (rgba 0 0 0 0.16)
        , Color.text (rgba 0 0 0 0.87)
        , Border.top 1
        , Border.left 1
        , Border.bottom 2
        , Border.right 2
        , Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Font.lineHeight 2
        , Font.alignRight
        ]
    , S.style (style Body)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text (rgba 0 0 0 0.87)
        ]
    , S.style (style Label)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text (rgba 0 0 0 0.54)
        , Transition.all
        ]
    , S.style (style FocussedLabel)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Color.text primaryColor
        , Transition.all
        ]
    , S.style (style FloatingLabel)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Color.text (rgba 0 0 0 0.54)
        , Transition.all
        ]
    , S.style (style TextInput)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text (rgba 0 0 0 0.87)
        , Color.border (rgba 0 0 0 0.42)
        , Border.bottom 1
        , S.hover
            [ Color.border (rgba 0 0 0 0.84)
            , Border.bottom 2
            ]
        , S.focus
            [ Color.text (rgba 0 0 0 0.87)
            , Color.border primaryColor
            , Border.bottom 2
            , S.prop "caret-color" "primaryColor"
            , S.prop "outline" "none"
            , S.prop "-webkit-box-shadow" "none"
            , S.prop "box-shadow" "none"
            ]
        ]
    , S.style (style FocussedTextInput)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text (rgba 0 0 0 0.87)
        , Color.border primaryColor
        , Border.bottom 2
        , S.pseudo "disabled"
            [ Color.background white
            ]
        , S.focus
            [ Color.text (rgba 0 0 0 0.87)
            , Color.border primaryColor
            , S.prop "caret-color" "#F7941E"
            , S.prop "outline" "none"
            , S.prop "-webkit-box-shadow" "none"
            , S.prop "box-shadow" "none"
            ]
        ]
    , S.style (style DatePicker)
        [ Color.background white
        , Shadow.simple
        ]
    , S.style (style DatePickerYearHeader)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 14
        , Color.text (rgba 255 255 255 0.82)
        , Color.background primaryColor
        ]
    , S.style (style DatePickerDateHeader)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 24
        , Color.text (rgba 255 255 255 0.92)
        , Color.background primaryColor
        ]
    , S.style (style DatePickerMonthSelection)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 14
        , Font.bold
        , Color.text (rgba 0 0 0 0.87)
        , Color.background white
        ]
    , S.style (style DatePickerContainer)
        [ S.prop "text-align" "center"
        ]
    , S.style (style DatePickerSelectedContent)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Color.text (rgba 255 255 255 0.92)
        , Color.background white
        , S.prop "text-align" "center"
        , S.prop "border-radius" "50%"
        , Color.background primaryColor
        ]
    , S.style (style DatePickerContent)
        [ Font.typeface [Font.font "Avenir"]
        , Font.size 12
        , Color.text (rgba 0 0 0 0.87)
        , Color.background white
        , S.prop "text-align" "center"
        , S.hover
            [ S.prop "border-radius" "50%"
            , Color.background (rgba 247 148 30 0.67)
            ]
        ]
    , S.style (style DisabledFlatButton)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text gray
        , Color.background white
        ]
    , S.style (style Select)
        [ Color.background white
        , Shadow.simple
        ]
    , S.style (style SelectOption)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text (rgba 0 0 0 0.87)
        , S.hover
            [ Color.background (rgba 0 0 0 0.12)
            ]
        ]
    , S.style (style SelectedOption)
        [ Font.typeface [Font.font "Avenir"]
        , Color.text primaryColor
        , S.hover
            [ Color.background (rgba 0 0 0 0.12)
            ]
        ]
    , S.style (style SelectArrow)
        [ S.pseudo ":after"
            [ S.prop "content" "\" \""
            , S.prop "posotion" "absolute"
            , S.prop "top" "-2px"
            , S.prop "left" "0"
            , S.prop "width" "0"
            , S.prop "height" "0"
            , S.prop "border-left" "5px solid transparent"
            , S.prop "border-right" "5px solid transparent"
            , S.prop "border-top" "5px solid rgba(0, 0, 0, 0.54)"
            ]
        ]
    ]
