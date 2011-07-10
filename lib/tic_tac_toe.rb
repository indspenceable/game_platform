class TicTacToe
  attr_accessor :board, :players, :current_turn
  def initialize players
    @board = Array.new(3) do
      Array.new(3) do
        nil
      end
    end
    @current_turn = 0
    @players = players
  end
  def current_player
    @players[@current_turn % @players.size]
  end
  def valid_move? player, move_json
    if move_json['type'] == 'play'
      x,y = move_json['loc']
      @board[x.to_i][y.to_i] == nil
    end
  end
  def submit player, move
    if move['type'] == 'play'
      x,y = move['loc']
      return false if (@board[x.to_i][y.to_i] != nil) || (player != current_player)
      @board[x.to_i][y.to_i] = player
      @current_turn+=1
      {'type' => 'play_square', 'player' => player, 'x' => x, 'y' => y, 'next_player' => current_player, 'next_turn' => @current_turn }
    else
      nil;
    end
  end
  def state_json player
    {'name' => player, 'current_player' => current_player, 'current_turn' => current_turn, 'board' => @board }.to_json
  end
end

