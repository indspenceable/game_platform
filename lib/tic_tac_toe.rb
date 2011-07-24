class TicTacToe
  attr_accessor :board, :players, :current_turn
  #API - initialize, with player list.
  #or, will this be game specific?#
  #whatever.
  def initialize players
    @board = Array.new(3) do
      Array.new(3) do
        nil
      end
    end
    @current_turn = 1
    @players = players
  end

  #API -> :player is submitting :move
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

  #API - return current state from perspective of :player
  def state_hash player
    {'name' => player, 'current_player' => current_player, 'current_turn' => current_turn, 'board' => @board }
  end

  def finished?
    rtn = nil
    3.times do |i|
        rtn ||= @board[0][i] if @board[0][i] == @board[1][i] && @board[1][i] == @board[2][i]
        rtn ||= @board[i][0] if @board[i][0] == @board[i][1] && @board[i][1] == @board[i][2]
    end
    rtn ||= @board[0][0] if @board[0][0] == @board[1][1] && @board[1][1] == @board[2][2]
    rtn ||= @board[2][0] if @board[2][0] == @board[1][1] && @board[1][1] == @board[0][2]
    puts "RTN is #{rtn}"
    return rtn
  end

  private

  def current_player
    @players[@current_turn % @players.size]
  end
end

