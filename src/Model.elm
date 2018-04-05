module Model exposing (..)

--Model


type alias Model =
    { deck : Deck
    , gameState : GameState
    , level : Level
    , movesCounter : Int
    }


type Msg
    = NoOp
    | CardClicked Card
    | ReceiveRandomDeck Deck
    | SetLevel Level
    | RestartGame


type CardState
    = Open
    | Closed
    | Matched


type Level
    = Easy
    | Medium
    | Hard


type alias Card =
    { id : String
    , state : CardState
    , group : Group
    }


type Group
    = A
    | B


type alias Deck =
    List Card


type GameState
    = Starting
    | Choosing
    | Matching
    | ClosingCards
    | GameOver
