class LobbyController < ApplicationController
  before_filter :require_login
  def lobby
  end
  #TODO - will eventually render a list of the players, and chat.
  # via => get
  # params -> date?
  # also, a list of your games?
  def poll
    render :json => {
    'players' => Player.where("last_activity > ?", 30.seconds.ago).map{|p| p.name},
    'game' => @player.game ? play_path(:game_name => @player.game.game_type, :game_id => @player.game.id) : "#"
    }
  end
end
