require 'tic_tac_toe.rb'
class GameController < ApplicationController
  before_filter :require_login

  def new_game
    #TODO We'll hopefully get a JSON list of player names
    targets = [@player] + (params['targets'].split(' ').map{ |x| Player.find_by_name(x) }.reject{|x| !x})
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
  def play
    @game = Game.find(params['game_id'])
  rescue
    flash[:error] = 'No game found!'
    redirect_to lobby_path 
  end

  # Get the game state, as a JSON
  # Optional Param: 'turn'
  #   Used to specificy the game state to get
  #   Defaults to the current state.
  #
  # On success, will return a json with keys
  # success => true, meta, and state
  #
  # On Failure, will return json with keys
  # success => false, error
  def state
    game = Game.find(params['game_id'])
    puts "p: #{params['turn']} #{!!params['turn']} #{params['turn'].class}"
    state = params['turn'] ? game.states.first(:turn_id => params['turn'].to_i) : game.current_state rescue nil
    if state
      render :json => {'success' => true, 'meta' => {'game_id' => game.id,'turn_number' => state.turn_id}, 'state' => state.data.state_hash(@player.name)}
    else
      render :json => {'success' => false,'error'=>"Unable to find that game state for #{params['turn']}"}
    end
  end

  #requires:
  #player -> @player.name
  #game_id -> @player.game.id
  def submit
    return json_error "Player name doesn't match logged in player." unless @player.name == params['player']
    game = @player.game
    return json_error "Game doesn't match current game." unless game.id == params['game_id'].to_i
    state = game.current_state
    return json_error "State doesn't match current_state" unless state.turn_id == params['turn_id'].to_i
    loaded_state = state.data

    if (!loaded_state.finished?) && (res = loaded_state.submit @player.name, params['move'])
      #Do we need to make one delta for each person in the game?
      #probably.
      game.deltas.create(:turn_id => state.turn_id, :data => res)
      new_state = game.states.create(:turn_id => state.turn_id + 1, :data => loaded_state)
      if winner = loaded_state.finished?
        game.update_attribute(:winner, winner)
      end
      render :json => true
    else
      render :json => false
    end
  end

  #Get all changes to the gamestate.
  #Ask given the current gamestate, and if there is an update, you will receive
  # the delta to the next gamestate for this player.
  # REQUIRES -> game_id, turn_id, player
  def deltas 
    game = Game.find(params['game_id'].to_i) rescue nil
    turn_id = params['turn_id'].to_i rescue nil
    return json_error "Player_id didn't match up with session." unless @player.name == params['player']

    #catch invalid requests
    return json_error 'Invalid game id' unless game

    #current_state = game.current_state
    #return json_error "Did not submit to the current state_id (Got:#{turn_id}, was looking for #{current_state.turn_id})" unless current_state.turn_id == turn_id

    delta=game.deltas.find(:first,:conditions => {:turn_id => turn_id}).data rescue nil

    return json_error "No delta for that state." unless delta
    render :json => {'success' => true, 'delta' => delta}
  end
end
