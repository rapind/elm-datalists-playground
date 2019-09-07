module DataList exposing (..)

import Browser
import Html exposing (Html, button, datalist, div, input, p, text)
import Html.Attributes exposing (class, disabled, id, list, name, value)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODELS


type alias DropDown =
    { id : Int
    , value : String
    }


type alias Option =
    { id : Int
    , name : String
    , disabled : Bool
    }


type alias Model =
    { dropDowns : List DropDown
    , options : List Option
    }


init =
    { dropDowns =
        List.repeat 256 0
            |> List.indexedMap (\n _ -> DropDown (n + 1) "")
    , options =
        List.repeat 256 0
            |> List.indexedMap (\n _ -> Option (n + 1) ("Label for " ++ String.fromInt (n + 1)) False)
    }



-- HELPERS


getOptionByName : List Option -> String -> Maybe Option
getOptionByName options name =
    List.filter (\o -> o.name == name) options
        |> List.head



-- UPDATE


type Msg
    = SelectedItem DropDown String
    | ClearInvalidSelections


updateOptions : Model -> Model
updateOptions model =
    let
        -- Loop through the options setting each to disabled if a matching dropDown value is the same as it's name
        optionIsSelected : Option -> Bool
        optionIsSelected option =
            List.any (\d -> d.value == option.name) model.dropDowns

        updateOption : Option -> Option
        updateOption option =
            { option | disabled = optionIsSelected option }
    in
    { model | options = List.map updateOption model.options }


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectedItem onDropDown value ->
            let
                updateDropDown dropDown =
                    if dropDown.id == onDropDown.id then
                        { dropDown | value = value }

                    else
                        dropDown

                updateDropDowns =
                    List.map updateDropDown model.dropDowns
            in
            { model | dropDowns = updateDropDowns }
                |> updateOptions

        ClearInvalidSelections ->
            -- TODO
            model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text "Used the datalist element to repeat a list of dropdowns that share the same options. When an option is selected in any of the dropdowns it will be disabled in the datalist and can't be selected again." ]
        , datalist [ id "options" ] (List.map viewOption model.options)
        , button [ onClick ClearInvalidSelections ] [ text "Clear invalid selections" ]
        , viewDropDowns model.dropDowns
        ]


viewOption : Option -> Html Msg
viewOption option =
    Html.option [ disabled option.disabled ] [ text option.name ]


viewDropDowns : List DropDown -> Html Msg
viewDropDowns dropDowns =
    Keyed.node "div"
        [ class "container" ]
        (List.map viewKeyedDropDown dropDowns)


viewKeyedDropDown : DropDown -> ( String, Html Msg )
viewKeyedDropDown dropDown =
    ( String.fromInt dropDown.id, lazy viewDropDown dropDown )


viewDropDown : DropDown -> Html Msg
viewDropDown dropDown =
    input
        [ list "options"
        , name (String.fromInt dropDown.id)
        , onInput (SelectedItem dropDown)
        ]
        []
