module Qit.DatePicker exposing (Message, State, update, view)

{-| DatePicker
-}

import Date exposing (Date)
import Date.Extra.Core exposing (daysInMonth, monthToInt, nextMonth, prevMonth)
import Date.Extra.Create exposing (dateFromFields)
import Date.Extra.Format as Format exposing (isoDateString)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input

import Qit.Style exposing (Style(..))

-- TODO year selection
-- TODO align day selection with day of week

type Message id = IgnoreInput String | Focus id (Maybe Date) | PreviousMonth | NextMonth | Dismiss | Select Date

type alias State id = 
    Maybe (InternalState id) 

type alias InternalState id = 
    { picker: id
    , showYear: Int
    , showMonth: Date.Month
    , selectedDate: Maybe Date
    }



update : Date -> State id -> Message id -> State id
update now state message =
    case message of
        Focus id value -> 
            let base = Maybe.withDefault now value
            in Just (InternalState id (Date.year base) (Date.month base) value)

        PreviousMonth ->
            state |> Maybe.map (\state -> 
                                   { state | showMonth = prevMonth state.showMonth
                                           , showYear = state.showYear - (if state.showMonth == Date.Jan then 1 else 0)
                                           })
        NextMonth ->
            state |> Maybe.map (\state ->
                                    { state | showMonth = nextMonth state.showMonth
                                            , showYear = state.showYear + (if state.showMonth == Date.Dec then 1 else 0)
                                            })
        Select value ->
            state |> Maybe.map (\state -> { state | selectedDate = Just value })

        Dismiss ->
            Nothing
            
        _ -> state

view : (Message id -> msg) -> (Style -> style) -> Date -> State id -> id -> String -> Maybe Date -> (Date -> msg) -> Element style variation msg
view lift style now stateQ id label currentValue message =
    let value = formatDate currentValue

        dateOptions = [onFocus <| lift <| Focus id currentValue]

        labelStyle = if value == "" then style Label else style FloatingLabel
        labelOptions = [height (px 16), inlineStyle [("pointer-events","none")]]
    in stateQ
        |> Maybe.andThen 
            (\state ->
                if state.picker /= id then
                    Nothing
                else
                    Just ( column (style None) [] 
                        [ el (style None) [height (px 45)]
                            ( Input.text (style FocussedTextInput) (inlineStyle [("z-index", "3")] :: dateOptions)
                                { onChange = lift << IgnoreInput
                                , value = value
                                , label = Input.labelAbove <| el (style FocussedLabel) (inlineStyle [("z-index", "4")] :: labelOptions) (text label)
                                , options = [Input.disabled]
                                }
                            )
                        
                            |> below
                                [ el (style None) [width (px 296), inlineStyle [("z-index", "3")]] (
                                    column (style DatePicker) [width fill]
                                        [ el (style DatePickerYearHeader) [width fill, paddingLeft 16, paddingTop 16] (
                                            text <| toString <| Maybe.withDefault state.showYear <| Maybe.map (\d -> Date.year d) state.selectedDate)
                                        , el (style DatePickerDateHeader) [width fill, paddingLeft 16, paddingTop 4, paddingBottom 16] (
                                            text <| formatHumanReadableDate state.selectedDate )
                                        , el (style None) [width fill, padding 8] (
                                            row (style None) [width fill, center]
                                                [ el (style None) [] (button (style DatePickerMonthSelection) [width (px 40), height (px 40), onClick (lift PreviousMonth)] (text "<"))
                                                , el (style None) [width fill, height (px 40)] (
                                                        el (style DatePickerMonthSelection) [center, verticalCenter] (text ((toString state.showMonth) ++ " " ++ (toString state.showYear)))
                                                    )
                                                , el (style None) [] (button (style DatePickerMonthSelection) [width (px 40), height (px 40), onClick (lift NextMonth)] (text ">"))
                                                ])
                                        , grid (style DatePickerContainer) [alignRight, paddingLeft 8, paddingRight 8]
                                            { columns = [ px 40, px 40, px 40, px 40, px 40, px 40, px 40 ]
                                            , rows    = [ px 40, px 40, px 40, px 40, px 40 ]
                                            , cells   = datePickerCellsFor style lift state (daysInMonth state.showYear state.showMonth)
                                            }
                                        , el (style None) [padding 8, alignRight] (
                                            row (style None) [spacing 8] 
                                                [ button (style FlatButton) [height (px 36), padding 8, minWidth (px 88), onClick (lift <| Dismiss)] (text "CANCEL")
                                                , case state.selectedDate of
                                                    Nothing -> button (style DisabledFlatButton) [height (px 36), padding 8, minWidth (px 88)] (text "OK")
                                                    Just date -> button (style FlatButton) [height (px 36), padding 8, minWidth (px 88), onClick (message date)] (text "OK")
                                                ])
                                        ])
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
                    ( Input.text (style TextInput) dateOptions
                            { onChange = lift << IgnoreInput
                            , value = value
                            , label = Input.labelAbove <| el labelStyle ((inlineStyle [("z-index", "1")] :: labelOptions) ++ (if value == "" then [moveDown 20] else [])) (text label)
                            , options = []
                            }
                    )
                ]
            )

datePickerCellsFor style lift state count =
    List.map (datePickerButtonForDay style lift state) (List.range 1 count)

datePickerButtonForDay style lift state day =
    datePickerButton style lift state day ((day % 7)-1) (day // 7) (toString day)

datePickerButton style lift state day x y caption =
    let s = case state.selectedDate of
                Nothing -> (style DatePickerContent)
                Just date -> if state.showYear == Date.year date && state.showMonth == Date.month date && day == Date.day date then
                                 (style DatePickerSelectedContent)
                             else
                                 (style DatePickerContent)
    in
        cell { start = ( x, y )
             , width = 1
             , height = 1
             , content = (button s [onClick (lift <| Select (dateFromFields state.showYear state.showMonth day 0 0 0 0))] (text caption))
             }

formatHumanReadableDate date =
    case date of 
        Nothing -> " "
        Just d -> (toString <| Date.dayOfWeek d) ++ ", " ++ (toString <| Date.month d) ++ " " ++ (toString <| Date.day d)

formatDate date = 
    case date of 
        Nothing -> ""
        Just d -> isoDateString d
