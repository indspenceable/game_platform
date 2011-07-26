require 'tic_tac_toe.rb'
class GameController < ApplicationController
  before_filter :require_login

  def new_game
    #TODO We'll hopefully get a JSON list of player names
    targets = [@player] + (params['targets'].split(' ').map{ |x| Player.find_by_name(x) }.reject{|x| !x})
    if targets.size > 1
      game = Game.create(:game_type => 'tic_tac_toe', :players => targets)
      puts "Game is #{game.inspect}"
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
    game = Game.find(params['game_id'])
  rescue
    flash[:error] = 'No game found!'
    redirect_to lobby_path 
  end

  # get the state of a game right now
  def state
    # Params -> :game, :game_id
    #state = YAML.load(@player.game.current_state.data)
    #render :json => {'game_id' =>@player.game.id, 'state' => state.state_hash(@player.name)}
    game = Game.find(params['game_id'])
    state = YAML.load(game.current_state.data)
    render :json => {'game_id' => game.id, 'state' => stae.state_hash(@player.name)}
  end

  #submit some data.
  def submit
    game = @player.game
    state = game.current_state
    loaded_state = YAML.load(state.data)
    if (!loaded_state.finished?) && (res = loaded_state.submit @player.name, params)
      #t = Transition.new({:game_id => @game.game_id, :turn_id => (@game.move_id), :data => res.to_json})
      game.deltas.create(:turn_id => state.turn_id, :data => res.to_json)
      new_state = game.states.create(:turn_id => state.turn_id + 1, :data => loaded_state)

      if winner = loaded_state.finished?
        game.update_attribute(:winner, winner)
      end
      render :json => true
    else
      render :json => false
    end
  end

  #get any changes from other people's turns
  # params => current_turn
  def deltas 
    #    game = #@player.game
    puts "params: #{params['game_id']}"
    game = Game.find(params['game_id'].to_i) rescue nil
    puts "Game is #{game.inspect}"
    return render :json => {'no_game' => true} unless game
    #newest_turn = Game.find_newest_state(game_id);
    current_state = game.current_state
    ctn = params['current_turn'].to_i
    deltas = []
    while ctn < current_state.turn_id
      #transition = Transition.find(:first, :conditions => {:game_id => game_id, :turn_id => ctn})
      td = game.deltas.find(:first, :conditions => {:turn_id => ctn}).data
      deltas << JSON.parse(td)
      ctn += 1
    end
    render :json => {'game_over' => game.winner, 'deltas' => deltas}
  end
end
