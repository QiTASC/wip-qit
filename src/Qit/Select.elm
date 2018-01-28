module Qit.Select exposing (Message, State, update, view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input

import Qit.Style exposing (Style(..))



-- TODO vertical alignment of currently selected choice
-- TODO if need to scroll, then show scrollbars all the time



type Message id = IgnoreInput String | Focus id | Dismiss

type alias State id = 
    Maybe id 

update : State id -> Message id -> State id
update state message =
    case message of
        Focus id -> Just id
        Dismiss -> Nothing
        _ -> state

view : (Message id -> msg) -> (Style -> style) -> State id -> id -> String -> Maybe (String, String) -> List (String, String) -> ((String, String) -> msg) -> Element style variation msg
view lift style stateQ id label valueQ choices message =
    let value = valueQ |> Maybe.map (\(choice, value) -> value) |> Maybe.withDefault ""

        selectOptions = [onFocus <| lift <| Focus id]

        labelStyle = if value == "" then style Label else style FloatingLabel
        labelOptions = [height (px 16), inlineStyle [("pointer-events","none")]]
    in stateQ 
        |> Maybe.andThen
            (\state ->
                if state /= id then
                    Nothing
                else
                    Just ( column (style None) [] 
                        [ el (style None) [height (px 45)]
                            ( Input.text (style FocussedTextInput) (inlineStyle [("z-index", "3")] :: selectOptions)
                                { onChange = lift << IgnoreInput
                                , value = value
                                , label = Input.labelAbove <| el (style FocussedLabel) (inlineStyle [("z-index", "4")] :: labelOptions) (text label)
                                , options = [Input.disabled]
                                }
                            )
                            
                            |> within
                                [ el (style Select) [width (percent 100), maxHeight (px 180), yScrollbar, inlineStyle [("z-index", "3")]]
                                    ( column (style None) [width (percent 100), paddingTop 10, paddingBottom 10]
                                        (choices |> List.map (\(value, caption) -> 
                                                                   if Just (value, caption) == valueQ then
                                                                       el (style SelectedOption) [width (percent 100), paddingXY 20 10, onClick <| message (value, caption)] (text caption)
                                                                   else
                                                                       el (style SelectOption) [width (percent 100), paddingXY 20 10, onClick <| message (value, caption)] (text caption))
                                                             )
                                    )
                                ]
                        , el (style None) 
                            [inlineStyle [("position","fixed"), ("z-index","2")], width (percent 100), height (percent 99.99), onClick <| lift <| Dismiss]
                            (empty)
                        ]
                    )
            )
        |> Maybe.withDefault
            ( column (style None) []
                [ el (style None) [height (px 45)]
                    ( Input.text (style TextInput) selectOptions
                            { onChange = lift << IgnoreInput
                            , value = value
                            , label = Input.labelAbove <| el labelStyle ((inlineStyle [("z-index", "1")] :: labelOptions) ++ (if value == "" then [moveDown 20] else [])) (text label)
                            , options = []
                            }
                    )

                    |> within
                        [ el (style SelectArrow) [alignRight, width (px 15), height (px 10), moveDown 25] (empty)
                        ]
                ]
            )

