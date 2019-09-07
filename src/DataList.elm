module DataList exposing (..)

import Browser
import Html exposing (Html, datalist, div, input, p, text)
import Html.Attributes exposing (class, disabled, id, list, name, value)
import Html.Events exposing (onInput)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODELS


type alias DropDown =
    { id : Int
    , selectedOption : Maybe Option
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


type Msg
    = SelectedItem DropDown String


init =
    { dropDowns =
        List.repeat 512 0
            |> List.indexedMap (\n _ -> DropDown (n + 1) Nothing)
    , options =
        List.repeat 512 0
            |> List.indexedMap (\n _ -> Option (n + 1) ("Label for " ++ String.fromInt (n + 1)) False)
    }



-- HELPERS


getOptionFromName : Model -> String -> Maybe Option
getOptionFromName model name =
    List.filter (\o -> o.name == name) model.options
        |> List.head


disableSelectedOptions : Model -> Model
disableSelectedOptions model =
    let
        -- Get the list of options that have been selected
        selectedOptions : List Option
        selectedOptions =
            List.map (\d -> d.selectedOption) model.dropDowns
                |> List.filterMap identity

        -- Disable the option if it's in the list of selected options
        updateOption : Option -> Option
        updateOption option =
            if List.member option selectedOptions then
                { option | disabled = True }

            else
                option

        -- Disable the only selected options
        updatedOptions =
            List.map (\o -> { o | disabled = False }) model.options
                |> List.map updateOption
    in
    { model | options = updatedOptions }



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectedItem changeDropDown name ->
            let
                selectedOption =
                    getOptionFromName model name

                updateDropDown selected dropDown =
                    case selected of
                        Just val ->
                            if dropDown.id == changeDropDown.id then
                                { dropDown | selectedOption = Just val }

                            else
                                dropDown

                        Nothing ->
                            if dropDown.id == changeDropDown.id then
                                { dropDown | selectedOption = Nothing }

                            else
                                dropDown

                updatedDropDowns =
                    List.map (updateDropDown selectedOption) model.dropDowns
            in
            { model | dropDowns = updatedDropDowns }
                |> disableSelectedOptions



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text "Used the datalist element to repeat a list of dropdowns that share the same options. When an option is selected in any of the dropdowns it will be disabled in the datalist and can't be selected again." ]
        , datalist [ id "options" ] (List.map viewOption model.options)
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
