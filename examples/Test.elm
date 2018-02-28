import Html exposing (Html)
import Element exposing (..)
import Element.Attributes exposing (..)
import Style as S
import Qit.App as App
import Qit.Button as Button
import Qit.Cells as Cells
import Qit.Form as Form
import Qit.Style as Style exposing (Style)
import Date exposing (Date)

-- CONFIG

appConfig = App.config QitStyle

cellsConfig = Cells.config QitStyle CellsMessage .projects .months .name month cell |> Cells.withSelectionChange SelectionChanged

-- DATA MODEL
type alias Project = 
    { name: String
    }

type alias Month = 
    { year: Int
    , month: Int
    }

month: Month -> String
month m = toString(m.year) ++ "-" ++ toString(m.month)

cell : Model -> Project -> Month -> String
cell _ p m = ""

-- APPLICATION

type alias Model =
    { projects: List Project
    , months: List Month
    , cells: Cells.Model Project Month
    }

type Message = Nop | CellsMessage (Cells.Message Project Month) | SelectionChanged

type QashStyles = None | QitStyle Style

init : (Model, Cmd Message)
init = { projects = [ Project "Project 1.0", Project "Project 1.5", Project "Project 2.0"]
       , months = [Month 2018 1, Month 2018 2, Month 2018 3, Month 2018 4, Month 2018 5, Month 2018 6]
       , cells = Cells.init
       } ! [Cmd.none]

update : Message -> Model -> (Model, Cmd Message)
update message model =
    case message of
        CellsMessage inner -> 
            let (updatedCells, cmd) = Cells.update cellsConfig model.cells inner
            in { model | cells = updatedCells } ! [cmd]
        SelectionChanged ->
            ( model, Cmd.none )
        _ -> ( model, Cmd.none )

view : Model -> Html Message
view model = 
    Element.layout stylesheet <|
        el None [width fill] (
            column None [width fill]
                [ App.titleBar appConfig "Projects > Planning View"
                , row None []
                    [ el None [width fill] (
                            Cells.view cellsConfig model.cells model
                        )
                    , el None [width (px 450)] (
                            row None []
                                [ text (toString model.cells.selected)
                                , Button.flat QitStyle "Test" []
                                , Button.flat QitStyle "Long Button for Testing" []
                                ]
                        )
                    ]
                ]
        )

stylesheet =
    S.styleSheet
        ([ S.style None [] ] ++ (Style.default QitStyle))

subscriptions : Model -> Sub Message
subscriptions model = Sub.none

main =
  Html.program { init = init, view = view, update = update, subscriptions = subscriptions }
