module Qit.App exposing (..)

import Color
import Material.Icons.Action exposing (account_circle)
import Material.Icons.Navigation exposing (apps, menu)
import Material.Icons.Social exposing (notifications_none)
import Svg

import Element exposing (..)
import Element.Attributes exposing (..)

import Qit.Style exposing (Style(..))

-- TODO app definitions
-- TODO navigation definition
-- TODO configure notifications area
-- TODO configure user area

type Config style = 
    Config (InternalConfig style)

type alias InternalConfig style =
    { style : Style -> style
    }

config: (Style -> style) -> Config style
config style =
    Config ({ style = style
            })


titleBar: Config style -> String -> Element style variation msg
titleBar (Config config) title =
    el (config.style TitleBar) [width (percent 100), height (px 64), paddingXY 24 20]
        ( row (config.style None) [width (percent 100), height (px 24), spacing 8]
              [ el (config.style None) [width (px 24), height (px 24)]
                  (html (Svg.svg [] [menu (Color.rgba 255 255 255 0.82) 24]))
              , spacer 2
              , el (config.style None) [width fill, height (px 24)]
                  (text title)
              , spacer 2
              , el (config.style None) [width (px 24), height (px 24)]
                  (html (Svg.svg [] [apps (Color.rgba 255 255 255 0.82) 24]))
              , spacer 1
              , el (config.style None) [width (px 24), height (px 24)]
                  (html (Svg.svg [] [notifications_none (Color.rgba 255 255 255 0.82) 24]))
              , spacer 1
              , el (config.style None) [width (px 40), height (px 40), moveUp 8]
                  (html (Svg.svg [] [account_circle (Color.rgba 255 255 255 0.82) 40]))
              ]
        )
