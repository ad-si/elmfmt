module Main exposing (x)


x =
    [ fromUnstyled <|
        viewChart
    ]


multipleItems =
    [ fromUnstyled <|
        viewChart
    , other
    ]


nestedBackpipe =
    [ outerFunc <|
        innerFunc <|
            value
    ]
