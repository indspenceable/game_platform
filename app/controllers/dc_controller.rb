require 'tic_tac_toe.rb'
class DcController < ApplicationController

  before_filter :require_login

  #get any new chats
  def lobby
    @player_id = session[:player_id]
  end

  #change this players name - via POST
  def name
    return render :json => false.to_json unless Player.valid_name?(params['name'])
    new_name = params['name']
    if !!Player.find_by_name(new_name)
      return render :json => false.to_json
    else
      if session[:name]
        p = Player.find_by_name(session[:name])
        p.name = new_name
        p.save
      else
        p = Player.new(:name => new_name)
        p.save
      end
      session[:name] = new_name
      render :json => true.to_json
    end
  end
  
  def new_game
    return render :json => false.to_json  unless (session[:name] && (p = Player.find_by_name(session[:name])))
    game = Game.create(:game_type => 'tic_tac_toe', :players => [Player.find_by_name(session[:name])])
    #TODO - this needs to be able to make different types of games.
    st = game.states.create(:data => YAML.dump(TicTacToe.new([session[:name]])), :turn_id => 1);
    game.save
    return render :json => true.to_json
  end

  def game
    return redirect_to '/' unless (session[:name] && Player.find_by_name(session[:name])) 
    #@game = YAML.load(Game.find_newest_state(Player.find_by_name(session[:name]).game_id).state)
    player = Player.find_by_name(session[:name])
    return redirect_to '/' unless player.game
    #OK - we have a game
  end


  def poll_lobby
    p = Player.find_by_name(session[:name])
    return render :json => {'in_game' => true} if p.game
    render :json => {}
  end

  #challenge a player, or cancel a challenge
  def challenge
  end

  #accept a challenge
  def accept
  end

  # get the state of a game right now
  def state
    player = Player.find_by_name(session[:name])
    state = YAML.load(player.game.current_state.data)
    puts "State is a #{state.class} #{state.inspect}"
    render :json => (state.state_json(player.name))
  end

  #submit some data.
  def submit
    #@game = Game.find_newest_state(Player.find_by_name(session[:name]).game_id)
    player = Player.find_by_name(session[:name])
    game = player.game
    state = game.current_state
    loaded_state = YAML.load(state.data)
    res = loaded_state.submit player.name, params
    if res
      #t = Transition.new({:game_id => @game.game_id, :turn_id => (@game.move_id), :data => res.to_json})
      game.transitions.create(:turn_id => state.turn_id, :data => res.to_json)
      game.states.create(:turn_id => state.turn_id + 1, :data => loaded_state)
    end
    render :text => "Hello, world."
  end


  #get any changes from other people's turns
  def transitions
    #TODO - this doesn't work.
    #game_id = Player.find_by_name(session[:name]).game_id
    player = Player.find_by_name(session[:name])
    game = player.game
    #newest_turn = Game.find_newest_state(game_id);
    current_state = game.current_state
    ctn = params['current_turn'].to_i
    return render({:json => []}) if ctn == current_state.turn_id

    transitions = []
    while ctn < current_state.turn_id
      #transition = Transition.find(:first, :conditions => {:game_id => game_id, :turn_id => ctn})
      td = game.transitions.find(:first, :conditions => {:turn_id => ctn}).data
      transitions << JSON.parse(td)
      ctn += 1
    end
    render :json => transitions
  end
end
