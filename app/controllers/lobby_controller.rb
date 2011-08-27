require 'tic_tac_toe.rb'
class LobbyController < ApplicationController
  before_filter :require_login
  def lobby
    if @player.game.winner
      @player.game = nil
      @player.save
    end rescue nil
  end

  def issue_challenge
    targets = [@player] + params['targets'].split(' ').map{|n| Player.find_by_name(n)} rescue nil
    return json_error "Invalid target." unless targets
    klass = Module.const_get(params['game_type'])
    # Otherwise, create a game
    Game.create_with_klass_and_players klass, targets
    render :json => {'success' => true}
  end
  def poll
    render :json => {
      'games' => @player.games.map{|g| "<a href=#{play_path(:game_id => g.id)}>Play game #{g.id}</a>"}.join('<br/>')
    }
  end
end
