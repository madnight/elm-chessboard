module Chess.Board exposing (Board)

import Array exposing (Array)
import Chess.Square exposing (Square)

type alias Board = Array (Array Square)
