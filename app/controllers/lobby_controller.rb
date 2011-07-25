require 'tic_tac_toe.rb'
class LobbyController < ApplicationController
  before_filter :require_login
  def lobby
    if @player.game.completed
      @player.game = nil
      @player.save
    end rescue nil
  end

  #params -> players, challenges
  def poll
    @player.update_attribute(:game_id, nil) if @player.game.completed rescue nil

    player_list = Player.where("last_activity > ?", 30.seconds.ago).map{|p| p.name}.reject{|p| p == @player.name}
    ppm = params['players'] || []

    challenge_list = Player.where(:current_challenge => @player.name).map{|p| p.name}
    ccm = params['challenges'] || []
    

    render :json => {
    'add_player' => player_list - ppm,
    'remove_player' => ppm - player_list,
    'challenge' => challenge_list - ccm,
    'unchallenge' => ccm - challenge_list,
    'redirect' => @player.one_time_redirect ? "#{play_path(:game_id => @player.game_id)}" : ''
    }
    @player.update_attribute(:one_time_redirect, false)
  end

  #params -> target
  def issue_challenge
    target = params['target']
    target_player = Player.find(:first, :conditions => {:name => target}) rescue nil
    p_in_game = @player.game rescue nil
    t_in_game = target_player.game rescue nil
    
    if target_player && !p_in_game && !t_in_game
      @player.update_attribute(:current_challenge,target)
      3.times {puts "*"}
      render :json => true
    else
      render :json => false
    end
  end

  #params -> target
  def accept_challenge
    target = params['target']
    target_player = Player.find(:first, :conditions => {:name => target}) rescue nil
    p_in_game = @player.game rescue nil
    t_in_game = target_player.game rescue nil
    puts "#{@player.name} is accepting challenge from #{target_player.name} they are #{p_in_game} and #{t_in_game} in games"
    if target_player && !p_in_game && !t_in_game && (target_player.current_challenge == @player.name)
      players = [@player,target_player]
      game = Game.create(:game_type => 'tic_tac_toe', :players => players)
      #TODO - this needs to be able to make different types of games.
      game.states.create(:data => YAML.dump(TicTacToe.new(players.map{|x| x.name})), :turn_id => 1);
      game.save
      players.each do |p|
        p.update_attributes(:current_challenge => nil,:one_time_redirect => true)
        p.save
      end
      return render :json => {'success' => true, 'game_id' => game.id}
    else
      render :json => false
    end
  end
end
