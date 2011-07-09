class TicTacToe
  def initialize players = ['dannyz','bobz']
    @board = Array.new(3) do
      Array.new(3) do
        nil
      end
    end
  end
  def submit player, move_json
    if move_json['type'] == 'play'
      x,y = move_json['loc']
      @board[x][y] = player
    end
  end
  def state_json player
    @board.to_json 
  end
end

