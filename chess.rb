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
    player_to_pick == @player1 ? other_player = @player2 : other_player = @player1
    color == "white" ? other_color = "black" : other_color = "white"
    @color_player_dictionary[other_color] = other_player
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

  #changing some stuff

  def start_the_game()
    color_to_play = "white"
    until checkmate?() || stalemate?()
      player_to_play = @color_player_dictionary[color_to_play]
      player_to_play.get_move() ## need to write this!
      switch_players!()
    end
    announce_winner()
  end

end



class Player
  attr_reader :name, :number_of_wins, :number_of_draws, :matches_played
  def initialize(name)
    @name = name
    @number_of_wins = 0
    @number_of_draws = 0
    @matches_played = 0
  end
end


class ChessBoard

  def initialize()
    @boxes = Array.new(8) { Array.new(8, nil) }
    assign_box_colors()
    place_starting_pieces()
    @captured_pieces = []
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
      @boxes[row][0].piece = Rook.new(color)
      @boxes[row][7].piece = Rook.new(color)
      @boxes[row][1].piece = Knight.new(color)
      @boxes[row][6].piece = Knight.new(color)
      @boxes[row][2].piece = Bishop.new(color)
      @boxes[row][5].piece = Bishop.new(color)
      @boxes[row][3].piece = Queen.new(color)
      @boxes[row][4].piece = King.new(color)
    end
    #assign pawns to squares
    [1, 6].each do |row|
      (0..7).each do |col|
        row == 1 ? color = :black : color = :white
        @boxes[row][col].piece = Pawn.new(color)
      end
    end
  end

  def move_piece(source_row, source_col, dest_row, dest_col)
    moved_piece = @boxes[source_row][source_col].piece
    destination_box = @boxes[dest_row][dest_col]
    if destination_box.has_ally_piece?(moved_piece.color)
      puts "You can't move to this square. It's already occupied by one of your other pieces."
      return false
    end

    moved_piece.generate_possible_moves(source_row, source_col)
    moved_piece.trace_path

    if @boxes[dest_row][dest_col].has_enemy_piece?
      if moved_piece.can_capture?()
        @captured_pieces << @boxes[dest_row][dest_col].piece
        @boxes[dest_row][dest_col].piece = moved_piece
      else
        puts "You can't make a capture on this square with a #{moved_piece.class}."
        return false
      end
    end

    moved_piece.has_moved = true

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



end


class Piece
  attr_reader :color
  attr_accessor :has_moved
  def initialize(color)
    @color = color
    @symbol = assign_symbol(color)
    @has_moved = false
  end

  def assign_symbol(color)
  end

  def display()
    @symbol
  end

  def can_capture?(source_row, source_col, dest_row, dest_col)
  end

  def generate_possible_moves(source_row, source_col)
  end

  def trace_path(source_row, source_col, dest_row, dest_col)
    path = PathTrace.new(source_row, source_col, dest_row, dest_col)
  end
end


class PathTrace
  def initialize(source_row, source_col, dest_row, dest_col)
    @source_col = source_col
    @source_row = source_row
    @dest_col = dest_col
    @dest_row = dest_row
    @path_coords = []
    trace_path()
  end

  def trace_path()
    lower_x, higher_x = [@source_col, @dest_col].min, [@source_col, @dest_col].max
    lower_y, higher_y = [@source_row, @dest_row].min, [@source_row, @dest_row].max
    (lower_y..higher_y).each do |row|
      (lower_x..higher_x).each do |col|
        @path_coords << [row, col]
      end
    end
    @path_coords.reverse! if path_coords[0] != [@source_row, @source_col]
  end

end


class Bishop < Piece
  def assign_symbol(color)
    color == :white ? "\u2657".encode('utcf-8') : "\u265D".encode('utf-8')
  end
  def generate_possible_moves(source_row, source_col)
    possible_moves = []
    row = source_row
    col = source_col
    while row < 7 && col < 7
      row += 1
      col += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row > 0 && col < 7
      row -= 1
      col += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row > 0 && col > 0
      row -= 1
      col -= 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
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
  def generate_possible_moves(source_row, source_col)
    possible_moves = []
    possible_moves.push(*[-1, 1, 0].product([-1, 1, 0]))
    possible_moves.select { |row, col| row >= 0 && row <= 7 && col >= 0 && col <= 7 }
  end
end


class Knight < Piece
  def assign_symbol(color)
    color == :white ? "\u2658".encode('utf-8') : "\u265E".encode('utf-8')
  end
  def generate_possible_moves(source_row, source_col)
    possible_moves = []
    possible_moves.push(*[-1, 1].product([-2, 2]))
    possible_moves.push(*[-2, 2].product([-1, 1]))
    possible_moves.select { |row, col| row >= 0 && row <= 7 && col >= 0 && col <= 7 }
  end
end


class Pawn < Piece
  def assign_symbol(color)
    color == :white ? "\u2659".encode('utf-8') : "\u265F".encode('utf-8')
  end
  def generate_possible_moves(source_row, source_col)
    possible_moves = []
    if @color == :white
      possible_moves << [source_row + 1, source_col]
      possible_moves << [source_row + 1, source_col - 1]
      possible_moves << [source_row + 1, source_col + 1]
      if has_moved = false
        possible_moves << [source_row + 2, source_col]
      end
    elsif @color == :black
      possible_moves << [source_row - 1, source_col]
      possible_moves << [source_row - 1, source_col - 1]
      possible_moves << [source_row - 1, source_col + 1]
      if has_moved = false
        possible_moves << [source_row - 2, source_col]
      end
    end
    possible_moves.select { |row, col| row >= 0 && row <= 7 && col >= 0 && col <= 7 }
  end
end


class Queen < Piece
  def assign_symbol(color)
    color == :white ? "\u2655".encode('utf-8') : "\u265B".encode('utf-8')
  end
  def generate_possible_moves(source_row, source_col)
    possible_moves = []
    row = source_row
    col = source_col
    while row < 7
      row += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row > 0
      row -= 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while col > 0
      col -= 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while col < 7
      col += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row < 7 && col < 7
      row += 1
      col += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row > 0 && col < 7
      row -= 1
      col += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row > 0 && col > 0
      row -= 1
      col -= 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
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
  def generate_possible_moves(source_row, source_col)
    possible_moves = []
    row = source_row
    col = source_col
    while row < 7
      row += 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while row > 0
      row -= 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while col > 0
      col -= 1
      possible_moves << [row, col]
    end
    row = source_row
    col = source_col
    while col < 7
      col += 1
      possible_moves << [row, col]
    end
    possible_moves
  end
end
