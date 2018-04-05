module DeckGen exposing (generateStaticDeck)

import Model exposing (..)


card1 : Card
card1 =
    { id = "1"
    , state = Open
    , group = A
    }


card2 : Card
card2 =
    { id = "2"
    , state = Closed
    , group = A
    }


card3 : Card
card3 =
    { id = "3"
    , state = Matched
    , group = A
    }


generateStaticDeck : Deck
generateStaticDeck =
    [ card1, card2, card3 ]
