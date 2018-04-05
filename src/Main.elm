module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import DeckGenerator
import Random


-- View


viewImage : Card -> Html Msg
viewImage card =
    img [ src ("/public/cats/" ++ card.id ++ ".jpg") ] []


viewCard : Card -> Html Msg
viewCard card =
    case card.state of
        Open ->
            div [ class "open" ] [ viewImage card ]

        Closed ->
            div
                [ class "closed"
                , onClick (CardClicked card)
                ]
                [ img [ src "/public/cats/closed.png" ] [] ]

        Matched ->
            div [ class "matched" ] [ viewImage card ]


viewCards : Model -> Html Msg
viewCards model =
    div [ class (toString model.level) ] (List.map viewCard model.deck)


page : Model -> Html Msg
page model =
    case model.gameState of
        Starting ->
            div []
                [ div [ class "row justify-content-md-center" ]
                    [ text "Heisann. Choose difficulty:" ]
                , div [ class "row justify-content-md-center" ]
                    [ button
                        [ class "btn btn-success h-75"
                        , onClick (SetLevel Model.Easy)
                        ]
                        [ text "Easy" ]
                    ]
                , div [ class "row justify-content-md-center" ]
                    [ button
                        [ class "btn btn-warning h-75"
                        , onClick (SetLevel Model.Medium)
                        ]
                        [ text "Medium" ]
                    ]
                , div [ class "row justify-content-md-center" ]
                    [ button
                        [ class "btn btn-danger h-75"
                        , onClick (SetLevel Model.Hard)
                        ]
                        [ text "Hard" ]
                    ]
                ]

        Choosing ->
            div []
                [ text ("Game On!  Difficulty:" ++ (toString model.level))
                , viewCards model
                , div [ class "row justify-content-md-center" ] [ text ("Amount of tries so far: " ++ toString model.movesCounter) ]
                , div [ class "row justify-content-md-center" ]
                    [ button [ class "btn btn-primary", onClick Model.RestartGame ] [ text "New Game" ] ]
                ]

        Matching ->
            div []
                [ text ("Game On!  Difficulty:" ++ (toString model.level))
                , viewCards model
                , div [ class "row justify-content-md-center" ] [ text ("Amount of tries so far: " ++ toString model.movesCounter) ]
                , div [ class "row justify-content-md-center" ]
                    [ button [ class "btn btn-primary", onClick Model.RestartGame ] [ text "New Game" ] ]
                ]

        ClosingCards ->
            div []
                [ text ("Game On!  Difficulty:" ++ (toString model.level))
                , viewCards model
                , div [ class "row justify-content-md-center" ] [ text ("Amount of tries so far: " ++ toString model.movesCounter) ]
                , div [ class "row justify-content-md-center" ]
                    [ button [ class "btn btn-primary", onClick Model.RestartGame ] [ text "New Game" ] ]
                ]

        GameOver ->
            div []
                [ div [ class "row justify-content-md-center" ] [ text ("Victory!") ]
                , div [ class "row justify-content-md-center" ] [ text ("You used " ++ toString model.movesCounter ++ "moves") ]
                , div [ class "row justify-content-md-center" ]
                    [ button [ class "btn btn-primary", onClick Model.RestartGame ] [ text "New Game" ] ]
                ]


view : Model -> Html Msg
view model =
    div []
        [ page model
        , infoPane model
        ]


infoPane : Model -> Html Msg
infoPane model =
    div [ class "row justify-content-md-center" ]
        []



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetLevel level ->
            ( { model | level = level }
            , Random.generate ReceiveRandomDeck (DeckGenerator.generateRandomDeck level)
            )

        CardClicked cardClicked ->
            if model.gameState == ClosingCards then
                ( doStuff cardClicked model, Cmd.none )
            else
                ( setCardClicked model cardClicked
                    |> doStuff cardClicked
                , Cmd.none
                )

        ReceiveRandomDeck deck ->
            ( { model | deck = deck, gameState = Choosing }, Cmd.none )

        RestartGame ->
            let
                ( model, cmd ) =
                    init
            in
                ( model, Cmd.none )


notMatchedCard : Card -> Bool
notMatchedCard card =
    if card.state == Matched then
        False
    else
        True


init : ( Model, Cmd Msg )
init =
    ( { deck = []
      , gameState = Starting
      , level = Easy
      , movesCounter = 0
      }
    , Cmd.none
    )



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Helper Functions


doStuff : Card -> Model -> Model
doStuff cardClicked model =
    case model.gameState of
        Starting ->
            model

        Choosing ->
            { model | gameState = Matching }

        Matching ->
            if matchesAnOpenCard cardClicked model.deck then
                { model
                    | deck = setCardsWithIdMatched cardClicked.id model.deck
                    , movesCounter = model.movesCounter + 1
                    , gameState = isGameFinished (setCardsWithIdMatched cardClicked.id model.deck)
                }
            else
                { model
                    | gameState = ClosingCards
                    , movesCounter = model.movesCounter + 1
                }

        ClosingCards ->
            { model
                | gameState = Choosing
                , deck =
                    List.map
                        (\c ->
                            if c.state == Open then
                                { c | state = Closed }
                            else
                                c
                        )
                        model.deck
            }

        GameOver ->
            model


isGameFinished : Deck -> GameState
isGameFinished deck =
    if List.any incompleteCard deck then
        Choosing
    else
        GameOver


incompleteCard : Card -> Bool
incompleteCard card =
    if card.state == Open || card.state == Closed then
        True
    else
        False



-- Skal bli true hvis alle kort i deck har state == Matched


matchesAnOpenCard : Card -> Deck -> Bool
matchesAnOpenCard cardClicked deck =
    let
        isMatch : Card -> Bool
        isMatch card =
            card.id
                == cardClicked.id
                && card.group
                /= cardClicked.group
                && card.state
                == Open
    in
        List.any isMatch deck


setCardsWithIdMatched : String -> Deck -> Deck
setCardsWithIdMatched cardId deck =
    List.map
        (\c ->
            if c.id == cardId then
                { c | state = Matched }
            else
                c
        )
        deck


closeAllCards : Deck -> Deck
closeAllCards deck =
    List.map
        (\c ->
            if c.state == Open then
                { c | state = Closed }
            else
                c
        )
        deck


setCardClicked : Model -> Card -> Model
setCardClicked model cardClicked =
    { model
        | deck =
            List.map
                (\c ->
                    if c.id == cardClicked.id && c.group == cardClicked.group then
                        { c | state = Open }
                    else
                        c
                )
                model.deck
    }
