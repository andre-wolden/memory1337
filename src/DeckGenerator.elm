module DeckGenerator exposing (random, static, generateRandomDeck)

import Model exposing (Deck, Card, Group(..), CardState(..), Level)
import Random
import Random.List


random : Urls -> Random.Generator Deck
random urls =
    static urls
        |> Random.List.shuffle


static : Urls -> Deck
static urls =
    let
        groupA =
            urls |> List.map (\url -> { id = url, group = A, state = Closed })

        groupB =
            urls |> List.map (\url -> { id = url, group = B, state = Closed })
    in
        List.concat [ groupA, groupB ]


generateRandomDeck : Level -> Random.Generator Deck
generateRandomDeck level =
    let
        urls_easy : Urls
        urls_easy =
            [ "1"
            , "2"
            , "3"
            ]

        urls_medium : Urls
        urls_medium =
            [ "1"
            , "2"
            , "3"
            , "4"
            , "5"
            , "6"
            ]

        urls_hard : Urls
        urls_hard =
            [ "1"
            , "2"
            , "3"
            , "4"
            , "5"
            , "6"
            , "7"
            , "8"
            , "9"
            ]
    in
        if level == Model.Hard then
            random urls_hard
        else if level == Model.Medium then
            random urls_medium
        else
            random urls_easy


type alias Urls =
    List String
