class Player
  attr_reader :name, :number_of_wins, :number_of_draws, :matches_played
  attr_accessor :color
  def initialize(name)
    @name = name
    @number_of_wins = 0
    @number_of_draws = 0
    @matches_played = 0
  end
  def get_move(board)
    # pieces = board.collect_pieces()
    # my_pieces = pieces.select { |piece| piece.color == @color }
    loop do
      puts "Enter the row col coordinates (0-7) of the piece you want to move (e.g. 3,2):"
      source_row, source_col = gets.chomp.split(',').map(&:to_i)
      puts "Enter the row col coordinates (0-7) of where you want to move (e.g. 3,2):"
      dest_row, dest_col = gets.chomp.split(',').map(&:to_i)
      if board.valid_move?(source_row, source_col, dest_row, dest_col)
        return [source_row, source_col, dest_row, dest_col]
      end
      puts "Move not valid. Please try again."
    end

  end

end


class ChessBoard
attr_reader :boxes
  def initialize()
    @boxes = Array.new(8) { Array.new(8, nil) }
    assign_box_colors()
    place_starting_pieces()
    @captured_pieces = []
  end

  def collect_pieces()
    pieces = []
    @boxes.each do |row|
      row.each do |box|
        pieces << box.piece unless box.piece.nil?
      end
    end
    pieces
  end

  def display()
    @boxes.each do |row|
      row.each do |box|
        print box.display_box
      end
      print "\n"
    end
  end

  def assign_box_colors()
    #populates boxes with colored Box objects starting in top left
    #corner then iterating row by row
    for row in (0..7)
      #alternates first box's color based on row
      if row % 2 == 0
        color = :white
      else
        color = :black
      end
      for col in (0..7)
        @boxes[row][col] = Box.new(color)
        color == :white ? color = :black : color = :white
      end
    end
  end

  def place_starting_pieces()
    #assign pieces to squares
    [0, 7].each do |row|
      row == 0 ? color = :black : color = :white
      @boxes[row][0].piece = Rook.new(color, row, 0)
      @boxes[row][7].piece = Rook.new(color, row, 7)
      @boxes[row][1].piece = Knight.new(color, row, 1)
      @boxes[row][6].piece = Knight.new(color, row, 6)
      @boxes[row][2].piece = Bishop.new(color, row, 2)
      @boxes[row][5].piece = Bishop.new(color, row, 5)
      @boxes[row][3].piece = Queen.new(color, row, 3)
      @boxes[row][4].piece = King.new(color, row, 4)
    end
    #assign pawns to squares
    [1, 6].each do |row|
      (0..7).each do |col|
        row == 1 ? color = :black : color = :white
        @boxes[row][col].piece = Pawn.new(color, row, col)
      end
    end
  end

  def valid_move?(source_row, source_col, dest_row, dest_col)
    return false if @boxes[source_row][source_col].piece.nil? #no piece in box, nothing to move!
    moved_piece = @boxes[source_row][source_col].piece
    legal_moves = moved_piece.generate_legal_moves(self)
    return true if legal_moves.include?([dest_row, dest_col])
    false
  end

  def move_piece(source_row, source_col, dest_row, dest_col)
    moved_piece = @boxes[source_row][source_col].piece
    destination_box = @boxes[dest_row][dest_col]

    #check for capture
    if @boxes[dest_row][dest_col].has_enemy_piece?(moved_piece.color)
        @captured_pieces << @boxes[dest_row][dest_col].piece
    end

    #check for queening
    if moved_piece.class == Pawn && moved_piece.color == :white && dest_row == 7
      moved_piece.queen()
    elsif moved_piece.class == Pawn && moved_piece.color == :black && dest_row == 0
      moved_piece.queen()
    end

    #need code to check for castling

    moved_piece.has_moved = true
    moved_piece.row = dest_row
    moved_piece.col = dest_col
    @boxes[dest_row][dest_col].piece = moved_piece
    @boxes[source_row][source_col].piece = nil
  end

  def check_for_check()
  end

end


class Box
  attr_accessor :piece

  def initialize(color)
    @piece = nil
    @color = color
  end

  def display_box()
    @piece.nil? ? "[ ]" : "[#{@piece.display()}]"
  end

  def has_enemy_piece?(moved_piece_color)
    return true if @piece != nil && @piece.color != moved_piece_color
    false
  end

  def has_ally_piece?(moved_piece_color)
    return true if @piece != nil && @piece.color == moved_piece_color
    false
  end

end


class Piece
  attr_reader :color
  attr_accessor :has_moved, :row, :col
  def initialize(color, row, col)
    @color = color
    @symbol = assign_symbol(color)
    @has_moved = false
    @row = row
    @col = col
  end

  def assign_symbol(color)
  end

  def display()
    @symbol
  end

  def generate_legal_moves(board)
    source_row = @row
    source_col = @col
    possible_moves = generate_possible_moves()
    pseudo_legal_moves = possible_moves.select do |dest_row, dest_col|
      path = PathTrace.new(source_row, source_col, dest_row, dest_col, board, @color)
      path.valid_path?()
    end
    pseudo_legal_moves
  end

  def can_capture?(dest_row, dest_col)
    true
  end

  def generate_possible_moves()
  end

end


class PathTrace

  def initialize(source_row, source_col, dest_row, dest_col, board, color)
    @source_row, @source_col = source_row, source_col
    @dest_row, @dest_col = dest_row, dest_col
    @boxes = board.boxes
    @color = color
    @path_coords = trace_path()
  end

  def valid_path?()
    if @boxes[@source_row][@source_col].piece.class == Knight
      if @boxes[@dest_row][@dest_col].has_ally_piece?(@color)
        return false
      else
        return true
      end
    end
    @path_coords.each do |row, col|
        return false if @boxes[row][col].has_ally_piece?(@color) #route blocked by allied piece
        return false if @boxes[row][col].has_enemy_piece?(@color) && [row, col] != [@dest_row, @dest_col] #route blocked by enemy piece
        return false if @boxes[@dest_row][@dest_col].has_enemy_piece?(@color) && !@boxes[@source_row][@source_col].piece.can_capture?(@dest_row, @dest_col) #destination blocked by enemy piece
    end
    true
  end

  def trace_path()
    path = []
    lower_x, higher_x = [@source_col, @dest_col].min, [@source_col, @dest_col].max
    lower_y, higher_y = [@source_row, @dest_row].min, [@source_row, @dest_row].max
    (lower_y..higher_y).each do |row|
      (lower_x..higher_x).each do |col|
        path << [row, col] unless [row, col] == [@source_row, @source_col]
      end
    end
    path
  end


end


class Bishop < Piece
  def assign_symbol(color)
    color == :white ? "\u2657".encode('utf-8') : "\u265D".encode('utf-8')
  end
  def generate_possible_moves()
    possible_moves = []
    row = @row
    col = @col
    while row < 7 && col < 7
      row += 1
      col += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row > 0 && col < 7
      row -= 1
      col += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row > 0 && col > 0
      row -= 1
      col -= 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row < 7 && col > 0
      row += 1
      col -= 1
      possible_moves << [row, col]
    end
    possible_moves
  end
end


class King < Piece
  def assign_symbol(color)
    color == :white ? "\u2654".encode('utf-8') : "\u265A".encode('utf-8')
  end
  def generate_possible_moves()
    possible_moves = []
    possible_moves.push(*[-1, 1, 0].product([-1, 1, 0]))
    possible_moves.select { |row, col| row >= 0 && row <= 7 && col >= 0 && col <= 7 }
  end
end


class Knight < Piece
  def assign_symbol(color)
    color == :white ? "\u2658".encode('utf-8') : "\u265E".encode('utf-8')
  end
  def generate_possible_moves()
    possible_moves = []
    possible_moves.push(*[-1, 1].product([-2, 2]))
    possible_moves.push(*[-2, 2].product([-1, 1]))
    possible_moves.map! { |row_incr, col_incr| [row_incr + @row, col_incr + @col] }
    possible_moves.select { |row, col| row >= 0 && row <= 7 && col >= 0 && col <= 7 }
  end
end


class Pawn < Piece
  def assign_symbol(color)
    color == :white ? "\u2659".encode('utf-8') : "\u265F".encode('utf-8')
  end

  def queen()
    #needs to be written!
  end

  def generate_possible_moves()
    possible_moves = []
    if @color == :white
      possible_moves << [@row - 1, @col]
      possible_moves << [@row - 1, @col - 1]
      possible_moves << [@row - 1, @col + 1]
      if has_moved == false
        possible_moves << [@row - 2, @col]
      end
    elsif @color == :black
      possible_moves << [@row + 1, @col]
      possible_moves << [@row + 1, @col - 1]
      possible_moves << [@row + 1, @col + 1]
      if has_moved == false
        possible_moves << [@row + 2, @col]
      end
    end
    possible_moves.select { |row, col| row >= 0 && row <= 7 && col >= 0 && col <= 7 }
  end
  def can_capture?(dest_row, dest_col)
    if @color == :white
      return true if (dest_row == @row - 1 && dest_col = @col - 1) || (dest_row == @row - 1 && dest_col = @col + 1)
    elsif @color == :black
      return true if (dest_row == @row + 1 && dest_col = @col - 1) || (dest_row == @row + 1 && dest_col = @col + 1)
    end
    false
  end
end


class Queen < Piece
  def assign_symbol(color)
    color == :white ? "\u2655".encode('utf-8') : "\u265B".encode('utf-8')
  end
  def generate_possible_moves()
    possible_moves = []
    row = @row
    col = @col
    while row < 7
      row += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row > 0
      row -= 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while col > 0
      col -= 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while col < 7
      col += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row < 7 && col < 7
      row += 1
      col += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row > 0 && col < 7
      row -= 1
      col += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row > 0 && col > 0
      row -= 1
      col -= 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row < 7 && col > 0
      row += 1
      col -= 1
      possible_moves << [row, col]
    end
    possible_moves
  end
end


class Rook < Piece
  def assign_symbol(color)
    color == :white ? "\u2656".encode('utf-8') : "\u265C".encode('utf-8')
  end
  def generate_possible_moves()
    possible_moves = []
    row = @row
    col = @col
    while row < 7
      row += 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while row > 0
      row -= 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while col > 0
      col -= 1
      possible_moves << [row, col]
    end
    row = @row
    col = @col
    while col < 7
      col += 1
      possible_moves << [row, col]
    end
    possible_moves
  end
end

class ChessGame
  attr_reader :board

  def initialize()
    @player1 = Player.new("Matt")
    @player2 = Player.new("Grace")
  end

  def select_piece_color()
    @color_player_dictionary = {}
    player_to_pick = [@player1, @player2].sample
    color = ""
    until valid_color_selection?(color)
      puts "Hey #{player_to_pick.name}! Do you want to play white or black?"
      color = gets.chomp.downcase
      puts "Color selection invalid. Please select either white or black." unless valid_color_selection?(color)
    end
    @color_player_dictionary[color] = player_to_pick
    player_to_pick.color = color.to_sym
    player_to_pick == @player1 ? other_player = @player2 : other_player = @player1
    color == "white" ? other_color = "black" : other_color = "white"
    @color_player_dictionary[other_color] = other_player
    other_player.color = other_color.to_sym
  end

  def valid_color_selection?(color)
    color == "white" || color == "black"
  end

  def new_game()
    @board = ChessBoard.new()
    @move_history = []
    select_piece_color()
    start_the_game()
  end

  def start_the_game()
    @color_to_play = "white"
    until checkmate?() || stalemate?()
      player_to_play = @color_player_dictionary[@color_to_play]
      puts "#{"*" * 20}"
      puts "#{@color_to_play.capitalize} to play."
      @board.display()
      move = player_to_play.get_move(@board)
      @board.move_piece(*move)
      switch_colors!()
    end
    announce_winner()
  end

  def switch_colors!()
    @color_to_play = @color_to_play == "white" ? "black" : "white"
  end

  def checkmate?()
    pieces = @board.collect_pieces
    #check if player to play's king is in check.
    #if in check, check if king has any valid moves
    #if no valid moves, return true
    false
  end

  def stalemate?()
    pieces = @board.collect_pieces
    #loop through player to play's pieces
    #check if any of his pieces have a valid move
    #if none have a move, return true
    false
  end

end
game = ChessGame.new
game.new_game()
# puts "pick a piece (row, col)"
# r = gets.chomp.to_i
# c = gets.chomp.to_i
# p game.board.boxes[r][c].piece
# puts "possible_moves:"
# p game.board.boxes[r][c].piece.generate_possible_moves()
# puts "psuedo_legal_moves:"
# p game.board.boxes[r][c].piece.generate_legal_moves(game.board)
# p game.board.valid_move?(0,1,2,2)
