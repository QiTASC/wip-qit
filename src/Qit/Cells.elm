module Qit.Cells exposing (..)

import Color
import List

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)

import Qit.Style exposing (Style(..))

-- TODO query select cell? or provide via message? or both (with generic SelectionChanged event)?
-- TODO select row/col
-- TODO multi-select
-- TODO cleanup exposed API

-- TODO inline edit -> is this really needed?

type Config model style msg row col = 
    Config (InternalConfig model style msg row col)

type alias InternalConfig model style msg row col =
    { style : Style -> style
    , lift : Message row col -> msg
    , rows : model -> List row
    , cols : model -> List col
    , rowHeader : row -> String
    , colHeader : col -> String
    , cell : model -> row -> col -> String
    , id : String
    }

config: (Style -> style) -> (Message row col -> msg) -> (model -> List row) -> (model -> List col) -> (row -> String) -> (col -> String) -> (model -> row -> col -> String) -> Config model style msg row col
config style lift rows cols rowHeader colHeader cell =
    Config ({ style = style
            , lift = lift
            , rows = rows
            , cols = cols
            , rowHeader = rowHeader
            , colHeader = colHeader
            , cell = cell
            , id = "cells" -- TOOD add possibility to update id
            })

type alias Model row col =
    { selected : Maybe (row, col)
    }

init : Model row col
init = Model Nothing

type Message row col = SelectCell (row, col)

update: Config model style msg row col -> Model row col -> Message row col -> Model row col
update config model message =
    case message of
        SelectCell cell -> { model | selected = Just cell }


view: Config model style msg row col -> Model row col -> model -> Element style variation msg
view (Config config) cellModel model =
    el (config.style None) [width (percent 100)] (
        column (config.style None) []
            ( columnHeaders config model :: columnData config cellModel model )
    )

columnHeaders config model =
    row (config.style None) []
        ( x config :: (config.cols model |> List.map (columnHeader config model))
        )

x config = el (config.style CellHeader) [width (px 128), height (px 24)] empty

columnHeader config model c =
    el (config.style CellHeader) [width (px 128), height (px 24)]
        ( text (config.colHeader c) )

columnData config cellModel model =
    config.rows model |> List.map 
        (\r ->
            row (config.style None) []
                ( rowHeader config cellModel model r ::
                  rowData config cellModel model r
                )
        )

rowHeader config cellModel model r =
     el (config.style CellHeader) [width (px 128), height (px 24)]
        ( text (config.rowHeader r) )

rowData config cellModel model r =
    config.cols model |> List.map
        ( \c ->
            if Just (r, c) == cellModel.selected then
                el (config.style SelectedCellData) [width (px 128), height (px 24), paddingRight 8, paddingLeft 8, onClick <| config.lift <| SelectCell (r, c)]
                            ( text (config.cell model r c) )
            else
                el (config.style CellData) [width (px 128), height (px 24), paddingRight 8, paddingLeft 8, onClick <| config.lift <| SelectCell (r, c)]
                            ( text (config.cell model r c) )
        )