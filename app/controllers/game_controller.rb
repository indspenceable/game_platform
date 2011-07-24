require 'tic_tac_toe.rb'
class GameController < ApplicationController

  before_filter :require_login

  def lobby
  end

  def quit
    @player.game.destroy
  end
  
  def new_game
    # We'll hopefully get a JSON list of player names
    targets = [@player] + (params['targets'].split(' ').map{ |x| Player.find_by_name(x) }.reject{|x| !x})
    
    puts "Params: #{params.inspect}"
    if targets.size > 1
      game = Game.create(:game_type => 'tic_tac_toe', :players => targets)
      #TODO - this needs to be able to make different types of games.
      st = game.states.create(:data => YAML.dump(TicTacToe.new(targets.map{|x| x.name})), :turn_id => 1);
      game.save
      return render :json => {'success' => true, 'game_id' => game.id}
    else
      return render :json => {'success' => false}
    end
  end

  # params -> game_id
  def game
    game = Game.find(params['game_id'])
  rescue
    flash[:error] = 'No game found!'
    redirect_to lobby_path 
  end

  # get the state of a game right now
  def state
    # Params -> :game, :game_id
    state = YAML.load(@player.game.current_state.data)
    render :json => {'game_id' =>@player.game.id, 'state' => state.state_hash(@player.name)}
  end

  #submit some data.
  def submit
    #@game = Game.find_newest_state(Player.find_by_name(session[:name]).game_id)
    #player = Player.find_by_name(session[:name])
    game = @player.game
    state = game.current_state
    loaded_state = YAML.load(state.data)
    res = loaded_state.submit @player.name, params
    if res
      #t = Transition.new({:game_id => @game.game_id, :turn_id => (@game.move_id), :data => res.to_json})
      game.transitions.create(:turn_id => state.turn_id, :data => res.to_json)
      new_state = game.states.create(:turn_id => state.turn_id + 1, :data => loaded_state)
      if loaded_state.finished?
        game.update_attribute(:completed, true)
      end
      render :json => true
    else
      render :json => false
    end
  end

  #TODO - will eventually render a list of the players, and chat.
  # via => get
  # params -> date?
  # also, a list of your games?
  def poll_lobby
    render :json => {
    'players' => Player.where("last_activity > ?", 30.seconds.ago).map{|p| p.name},
    'game' => @player.game ? game_path(:game_name => @player.game.game_type, :game_id => @player.game.id) : "#"
    }
  end

  #get any changes from other people's turns
  # params => current_turn
  def transitions
    #    game = #@player.game
    puts "params: #{params['game_id']}"
    game = Game.find(params['game_id'].to_i) rescue nil
    puts "Game is #{game.inspect}"
    return render :json => {'no_game' => true} unless game
    #newest_turn = Game.find_newest_state(game_id);
    current_state = game.current_state
    ctn = params['current_turn'].to_i
    transitions = []
    while ctn < current_state.turn_id
      #transition = Transition.find(:first, :conditions => {:game_id => game_id, :turn_id => ctn})
      td = game.transitions.find(:first, :conditions => {:turn_id => ctn}).data
      transitions << JSON.parse(td)
      ctn += 1
    end
    render :json => {'game_over' => game.completed, 'transitions' => transitions}
  end
end
