#Creating a Chess Game

##Rules of the Road
Description of Chess gameplay and rules found [here](https://en.wikipedia.org/wiki/Rules_of_chess "Chess rules")

##Functional Parts

The various pieces of the program should be broken down into separate objects.

* Game
* Board
* Pieces
* Players

###Game
A new chess game object should take two player objects as arguments and should contain the gameplay flow functions.

###Board
A new board object should be created by the game object during initialization. This board should record game state and manage some gameplay logic such as *check* and *checkmate*.

###Pieces
Each piece on the board should be initialized as an object of that piece's type. For example, new pawns should be created using a Pawn class and the queen should each be created as a Queen object. Piece logic should as whether a move is valid or whether a capture can be made should largely be contained in these classes. *Castling* might be a special case.

###Player
Should include details about the player and their match history.

##Suggested Program Architecture
* ChessGame
  - Item board: ChessBoard
  - Player1: Player
  - Player2: Player
  - moveHistory : Map<Player,List<[2][2]>>
  - selectedPieceColor : Map<Player,String>
  - selectPieceType(Player) : void
  - startTheGame() : void
  - announceWinner() : Player

* Player
  - Name : String
  - NoOfWins : int
  - NoOfDraws : int
  - matchesPlayed : List<String>

* board: ChessBoard
  - boxes : Box [8][8]
  - removedPieces : List<Piece>
  - movePiece(pieceColor, sourceX, sourceY, destX, destY) : boolean
  - checkforCheck() : boolean

* boxes: Box
  - piece : Piece
  - color : int
  - displayBox() : void

* piece: Piece
  - color : String
  - display()
  - tracePaths(sourceX, sourceY, destX, destY) : PathTrace

* PathTrace
  - sourceX : int
  - sourceY : int
  - destX : int
  - destY : int
  - hasValidTrace : boolean
  - trace : List<List<int[4][4]>>

* Bishop
* King
* Knight
* Pawn
* Queen
* Rook
