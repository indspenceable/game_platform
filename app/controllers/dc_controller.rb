require 'tic_tac_toe.rb'
class DcController < ApplicationController

  before_filter :require_login

  def lobby
  end

  def quit
    @player.game.destroy
  end
  
  def new_game
    # We'll hopefully get a JSON list of player names
    targets = [@player] + (params['targets'].split(',').map{ |x| Player.find_by_name(x) }.reject{|x| !x})
    
    if targets.size > 1
      game = Game.create(:game_type => 'tic_tac_toe', :players => targets)
      #TODO - this needs to be able to make different types of games.
      st = game.states.create(:data => YAML.dump(TicTacToe.new(targets.map{|x| x.name})), :turn_id => 1);
      game.save
      return render :json => true
    else
      return render :json => false
    end
  end

  # params -> game_id
  def game
    @game = Game.find(params[:game_id])
    redirect_to lobby_path unless @game
  end


  # get the state of a game right now
  def state
    # Params -> :game, :game_id
    #player = Player.find_by_name(session[:name])
    state = YAML.load(@player.game.current_state.data)
    puts "State is a #{state.class} #{state.inspect}"
    render :json => (state.state_json(@player.name))
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
      game.states.create(:turn_id => state.turn_id + 1, :data => loaded_state)
    end
    render :text => "Hello, world."
  end


  #this is the general polling method
  def poll
    if params['type'] == 'transitions'
      transitions
    else
      poll_lobby
    end
  end

  #TODO - will eventually render a list of the players, and chat.
  # via => get
  # params -> date?
  # also, a list of your games?
  def poll_lobby
    render :json => {}
    #the logic here should be split into sub tasks
  end

  #get any changes from other people's turns
  def transitions
    #TODO - this doesn't work.
    #game_id = Player.find_by_name(session[:name]).game_id
    #player = Player.find_by_name(session[:name])
    game = @player.game
    return render :json => {'game_over' => true} unless game
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
    render :json => {'game_over' => false, 'transitions' => transitions}
  end
end
