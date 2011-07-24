class LobbyController < ApplicationController
  before_filter :require_login
  def lobby
    @player.update_attribute(:game_id, nil) if @player.game.completed rescue nil
  end
  
  def poll
    render :json => {
    'players' => Player.where("last_activity > ?", 30.seconds.ago).map{|p| p.name}#,
    #'game' => @player.game ? 
    }
  end
end
