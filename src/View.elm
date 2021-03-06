module View exposing (view)

import Html exposing (Html, div, span, text, img)
import Html.App as App
import Html.Attributes exposing (style, src, width, height)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Actions exposing (Action(..))
import Dict
import Color exposing (Color)
import Chess.Types exposing (Square, Board, Rank, Player, Position, PlayerPiece, Move, MoveType(..), Piece(..))
import Chess.Pieces exposing (getPieceDisplayInfo, toPlayerPiece)

disablePiece : Player -> Maybe PlayerPiece -> Bool
disablePiece playerInTurn playerPieceMaybe =
  playerPieceMaybe
    |> Maybe.map (\playerPiece -> playerPiece.player /= playerInTurn)
    |> Maybe.withDefault False

renderPiece : Int -> Player -> Maybe PlayerPiece -> Html Action
renderPiece sideLength playerInTurn piece =
  let
    pieceDisplayInfo =
      getPieceDisplayInfo piece
    pieceOpacity =
      if (disablePiece playerInTurn piece) then
        ("opacity", "0.6")
      else
        ("opacity", "1")
    pieceStyle =
      pieceOpacity ::
        [ ("z-index", "1")
        , ("position", "absolute")
        , ("width", toString sideLength ++ "rem")
        , ("height", toString sideLength ++ "rem")
        ]

  in
    case pieceDisplayInfo of
      Just imageName ->
        img [ style pieceStyle, src ("assets/" ++ imageName) ]
            []
      Nothing ->
        div [] []

squareStyle sideLength color =
  style
    [ ("backgroundColor", color)
    , ("height", toString sideLength ++ "rem")
    , ("width", toString sideLength ++ "rem")
    ]

highlightStyle sideLength hightlightColor =
  style
    [ ("backgroundColor", hightlightColor)
    , ("opacity", "0.9")
    , ("position", "absolute")
    , ("width", toString sideLength ++ "rem")
    , ("height", toString sideLength ++ "rem")
    ]

squareSelectAction : Maybe Square -> Square -> Action
squareSelectAction fromSquareMaybe toSquare =
  case fromSquareMaybe of
    Nothing ->
      Select toSquare
    Just fromSquare ->
      case toSquare.moveToPlay of
        Just move ->
          MovePiece fromSquare.position move
        Nothing ->
          Select toSquare

renderSquare : Int -> Maybe Square -> Player -> Square -> Html Action
renderSquare sideLength selectedSquare playerInTurn square =
  let
    { file, rank } = square.position
    isSelected =
      case selectedSquare of
        Just selected ->
          selected == square
        Nothing ->
          False
    highlightColor =
      case square.moveToPlay of
        Just move ->
          case .moveType move of
            Goto ->
              "grey"
            PawnJump ->
              "grey"
            Capture ->
              "red"
            Enpassant ->
              "red"
            Promotion ->
              "orange"
            _ ->
              "blue"

        Nothing ->
          if isSelected then
            "yellow"
          else
            ""

    baseColor =
      if (file + rank) % 2 /= 0 then
        "white"
      else
        "green"
  in
    div [ squareStyle sideLength baseColor, onClick (squareSelectAction selectedSquare square) ]
      [ div [ highlightStyle sideLength highlightColor ] []
      , renderPiece sideLength playerInTurn square.piece
      ]

rankStyle sideLength =
  style
    [ ("height", toString sideLength ++ "rem")
    , ("display", "flex")
    ]

renderRank : Int -> Maybe Square -> Player -> Rank -> Html Action
renderRank sideLength selectedSquare playerInTurn rank =
  div [ rankStyle sideLength ]
    <| List.map (renderSquare sideLength selectedSquare playerInTurn)
      <| Dict.values rank

boardStyle sideLength =
  style
    [ ("box-shadow", "0 0 2rem -0.2rem black")
    , ("width", toString (sideLength * 8) ++ "rem")
    , ("height", toString (sideLength * 8) ++ "rem")
    , ("position", "absolute")
    ]

renderBoard : Int -> Maybe Square -> Player -> Board -> Html Action
renderBoard sideLength selectedSquare playerInTurn board =
  div [ boardStyle sideLength ]
    <| List.map (renderRank sideLength selectedSquare playerInTurn)
      <| List.reverse
        <| Dict.values board

promotePiecePickerStyle sideLength =
  style
    [ ("position", "absolute")
    , ("width", toString (sideLength * 4) ++ "rem")
    , ("height", toString (sideLength) ++ "rem")
    , ("backgroundColor", "white")
    , ("z-index", "2")
    , ("display", "flex")
    , ("border", "2px solid orange")
    ]

promotePieceStyle sideLength =
  style
    [ ("width", toString sideLength ++ "rem")
    , ("height", toString sideLength ++ "rem")
    ]

renderPromotePiecePicker : Int -> Player -> Maybe Position -> Html Action
renderPromotePiecePicker sideLength playerInTurn promote =
  let
    renderPromotePiece playerPiece position =
      div
      [ onClick (PromotePawn playerPiece position)
      , promotePieceStyle sideLength
      ]
      [ renderPiece sideLength playerInTurn (Just playerPiece)
      ]
  in
    case promote of
      Just position ->
        div [ promotePiecePickerStyle sideLength ]
          ( List.map
              (\piece -> renderPromotePiece (toPlayerPiece playerInTurn piece) position)
              [ R, N, B, Q ]
          )
      Nothing ->
        div [] []

viewStyle sideLength =
  style
    [ ("height", toString (sideLength * 8) ++ "rem")
    , ("width", toString (sideLength * 8) ++ "rem")
    , ("display", "flex")
    , ("align-items", "center")
    , ("justify-content", "center")
    ]

view : Model -> Html Action
view model =
  div [ viewStyle 5 ]
    [ renderBoard 5 model.selectedSquare model.playerInTurn model.boardView
    , renderPromotePiecePicker 7 model.playerInTurn model.promote
    ]
