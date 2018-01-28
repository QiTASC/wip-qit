module Qit.Form exposing (Config, Message, TransientState, config, dateField, selectField, textField, init, update, view)

import Array exposing (Array)
import Color exposing (..)
import Date exposing (Date)
import Task

import Element exposing (..)
import Element.Attributes exposing (..)

import Qit.DatePicker as DP
import Qit.Select as SL
import Qit.TextField as TF
import Qit.Style exposing (Style(..))



-- TODO safari hover over label doesn't hover input
-- TODO safari date picker has no separation between input and inline picker



type Config id model style msg = 
    Config (InternalConfig id model style msg)

type alias InternalConfig id model style msg =
    { lift : Message id -> msg
    , style : Style -> style
    , state: model -> TransientState id
    , updateState: model -> TransientState id -> model
    , fields : Array (Field id model)
    }

type Field id model
    = TextField { id: id
                , label: String
                , value: model -> String
                , update: model -> String -> model
                }
    | DateField { id: id
                , label: String
                , value: model -> Maybe Date
                , update: model -> Date -> model
                }
    | SelectField { id: id
                  , label: String
                  , choices: model -> List (String, String)
                  , value: model -> Maybe (String, String)
                  , update: model -> (String, String) -> model
                  }

type TransientState id
    = TransientState (InternalTransientState id)

type alias InternalTransientState id =
    { now : Date
    , date: DP.State id
    , select: SL.State id
    , text: TF.State id
    }

type Message id = CurrentDate Date | TextInput Int String | TextMessage (TF.Message id) | DateInput Int Date | DateMessage (DP.Message id) | SelectInput Int (String, String) | SelectMessage (SL.Message id)



config: (Message id -> msg) -> (Style -> style) -> (model -> TransientState id) -> (model -> TransientState id -> model) -> Config id model style msg
config lift style state updateState =
    Config ({ lift = lift
            , style = style
            , state = state
            , updateState = updateState
            , fields = Array.empty 
            })

dateField : id -> String -> (model -> Maybe Date) -> (model -> Date -> model) -> Config id model style msg -> Config id model style msg
dateField id label value update config =
    DateField { id = id, label = label, value = value, update = update }
        |> addTo config

selectField : id -> String -> (model -> Maybe (String, String)) -> (model -> List (String, String)) -> (model -> (String, String) -> model) -> Config id model style msg -> Config id model style msg
selectField id label value choices update config =
    SelectField { id = id, label = label, value = value, choices = choices, update = update }
        |> addTo config


textField : id -> String -> (model -> String) -> (model -> String -> model) -> Config id model style msg -> Config id model style msg
textField id label value update config = 
    TextField { id = id, label = label, value = value, update = update }
        |> addTo config
        
addTo : Config id model style msg -> Field id model -> Config id model style msg
addTo config field =
    case config of
        Config cfg ->
            Config ({ cfg | fields = Array.push field cfg.fields })



init : Config id model style msg -> (TransientState id, Cmd msg)
init config = 
    let cfg = case config of
                  Config c -> c
    in 
        ( TransientState ({ now = Date.fromTime 0, date = Nothing, select = Nothing, text = Nothing })
        , Task.perform (cfg.lift << CurrentDate) Date.now
        )



update: Config id model style msg -> Message id -> model -> model
update config message model =
    let cfg = case config of
                   Config c -> c
        state = case cfg.state model of
                    TransientState ts -> ts

    in internalUpdate cfg state message model

internalUpdate cfg state message model =
    case message of
        CurrentDate now ->
            cfg.updateState model (TransientState { state | now = now })

        TextMessage innerMsg ->
            let newText = TF.update state.text innerMsg
            in cfg.updateState model (TransientState { state | text = newText })

        TextInput index newValue ->
            Array.get index cfg.fields
                |> Maybe.andThen (\field -> case field of 
                                                TextField { update } -> Just (update model newValue)
                                                _ -> Nothing
                                 )
                |> Maybe.withDefault model

        DateMessage innerMsg ->
            let newDate = DP.update state.now state.date innerMsg
            in cfg.updateState model (TransientState { state | date = newDate })

        DateInput index newValue ->
            Array.get index cfg.fields
                |> Maybe.andThen (\field -> case field of 
                                                DateField { update } -> Just (cfg.updateState (update model newValue) (TransientState { state | date = Nothing }))
                                                _ -> Nothing
                                 )
                |> Maybe.withDefault model

        SelectMessage innerMsg ->
            let newSelect = SL.update state.select innerMsg
            in cfg.updateState model (TransientState { state | select = newSelect })

        SelectInput index newValue ->
            Array.get index cfg.fields
                |> Maybe.andThen (\field -> case field of 
                                                SelectField { update } -> Just (cfg.updateState (update model newValue) (TransientState { state | select = Nothing }))
                                                _ -> Nothing
                                 )
                |> Maybe.withDefault model

        -- _ -> model



view: Config id model style msg -> model -> Element style variation msg
view config model =
    let cfg = case config of
                   Config c -> c
        state = case cfg.state model of
                    TransientState ts -> ts

    in internalView cfg state model

internalView cfg state model =
    el (cfg.style None) [width fill] (
        column (cfg.style None) [width fill, spacing 15]
            <| Array.toList <| Array.indexedMap (viewField cfg state model) cfg.fields
    )

viewField : InternalConfig id model style msg -> InternalTransientState id -> model -> Int -> Field id model -> Element style variation msg
viewField cfg state model index field =
    case field of
        TextField { id, label, value } ->
            TF.view (cfg.lift << TextMessage) cfg.style state.text id label (value model) (cfg.lift << TextInput index)

        DateField { id, label, value } ->
            DP.view (cfg.lift << DateMessage) cfg.style state.now state.date id label (value model) (cfg.lift << DateInput index)

        SelectField { id, label, value, choices } ->
            SL.view (cfg.lift << SelectMessage) cfg.style state.select id label (value model) (choices model) (cfg.lift << SelectInput index)

