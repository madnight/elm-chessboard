module Model exposing (Model)

import Chess.Board exposing (Board, BoardRow)
import Chess.Piece exposing (Piece(..))
import Chess.Square exposing (Square)
import Chess.Position exposing (..)
import Chess.Players exposing (Player(..))

type Model =
  { board : Board
  }

createSquare : Rank -> File -> Maybe PlayerPiece -> Square
createSquare rank file piece =
  Square piece { file, rank }

createRank : Rank -> List (Maybe PlayerPiece) -> List Square
createRank rank pieceOrder =
  List.map2
    (createSquare rank)
    [ 1, 2, 3, 4, 5, 6, 7, 8 ]
    pieceOrder

emptyRank : Rank -> Array Square
emptyRank rank =
  Array.fromList
    <| createRank rank
    <| List.repeat 8 Nothing

initialFirstRank : Player -> Array Square
initialFirstRank player =
  let
    playerPieceOrder = List.map (PlayerPiece player) [ R, N, B, K, Q, B, N, R ]
    (rankNumber, pieceOrder) =
      case player of
        White -> (1, playerPieceOrder)
        Black -> (8, List.reverse playerPieceOrder)
  in
    Array.fromList
      <| createRank rankNumber
      <| List.map Just pieceOrder

initialSecondRank : Player -> Array Square
initialSecondRank player =
  let
    rankNumber =
      case player of
        White -> 2
        Black -> 7
    pieceOrder = List.map (PlayerPiece player) [ P, P, P, P, P, P, P, P ]
  in
    Array.fromList
      <| createRank rankNumber
      <| List.map Just pieceOrder

initial : Model
initial =
  { board = Array.fromList
      [ initialFirstRank White
      , initialSecondRank White
      , emptyRank 3
      , emptyRank 4
      , emptyRank 5
      , emptyRank 6
      , initialSecondRank Black
      , initialFirstRank Black
      ]
  }