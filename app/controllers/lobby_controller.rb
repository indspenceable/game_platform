class LobbyController < ApplicationController
  before_filter :require_login
  def lobby
    @game = @player.game
  rescue
    @player.update_attribute(:game_id, nil)
  end
  
  def poll
    render :json => {
    'players' => Player.where("last_activity > ?", 30.seconds.ago).map{|p| p.name}.reject{|p| p == @player.name}
    }
  end
end
