class DcController < ApplicationController
  def lobby
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
    p.game_id = Game.generate_new_game([session[:name],'enemy'])
    p.save
    return render :json => true.to_json
  end

  def game
    return redirect_to '/' unless (session[:name] && Player.find_by_name(session[:name])) 
    @game = YAML.load(Game.find_newest_state(Player.find_by_name(session[:name]).game_id).state)
    return redirect_to '/' unless @game
    #OK - we have a game
  end

  #get any new chats
  def lobby
  end

  #challenge a player, or cancel a challenge
  def challenge
  end

  #accept a challenge
  def accept
  end

  # get the state of a game right now
  def state
    @game = Game.find_newest_state(Player.find_by_name(session[:name]).game_id)
    state = YAML.load(@game.state)
    render :json => (state.state_json(session[:name]))
  end

  #submit some data.
  def submit
    @game = Game.find_newest_state(Player.find_by_name(session[:name]).game_id)
    state = YAML.load(@game.state)
    res = state.submit session[:name], params
    if res
      t = Transition.new({:game_id => @game.game_id, :turn_id => (@game.move_id), :data => res.to_json})
      g = Game.new({:game_id => @game.game_id, :move_id => (@game.move_id + 1), :state => state})
      g.save
      t.save
    else
    end
    render :text => "Hello, world."
  end


  #TODO - Change Game.move_id -> Game.turn_id
  #get any changes from other people's turns
  def transitions
    5.times do
      puts ""
    end
    game_id = Player.find_by_name(session[:name]).game_id
    puts "Our game id is #{game_id}"
    newest_turn = Game.find_newest_state(game_id);
    puts "Newest turn is #{newest_turn} with move number #{newest_turn.move_id}"
    ctn = params['current_turn'].to_i
    puts "They asked for #{ctn}"
    return render({:json => []}) if ctn == newest_turn.move_id

    transitions = []
    while ctn < newest_turn.move_id
      puts "Adding a transition"
      transition = Transition.find(:first, :conditions => {:game_id => game_id, :turn_id => ctn})
      transitions << JSON.parse(transition.data)
      ctn += 1
    end
    #games = Game.find(:first,:conditions => {:game_id => game_id, :move_id => turn_number+1})
    
    5.times do
      puts ""
    end
    render :json => transitions
  end
end
