class DcController < ApplicationController

  before_filter :require_login

  #get any new chats
  def lobby
    @player_id = session[:player_id]
  end

  #change this players name - via POST
  def name
    puts "HELLO WORLD."
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
    puts p
    p.game_id = Game.generate_new_game
    p.save
    return render :json => true.to_json
  end

  def game
    return redirect_to '/' unless (session[:name] && Player.find_by_name(session[:name])) 
    @game = Game.find_newest_state(Player.find_by_name(session[:name]).game_id)
    return redirect_to '/' unless @game
    puts "Game is #{@game.inspect}"
    @game = @game.json_for session[:name]
    puts "game is now <><><><><>#{@game}<><>>>>><><><><<>"
    #OK - we have a game
  end

  #challenge a player, or cancel a challenge
  def challenge
  end

  #accept a challenge
  def accept
  end

  # get the state of a game right now
  def state
  end

  #submit starting units
  def submit_units
  end

  #submit orders for a turn
  def submit_orders
  end

  #get any changes from other people's turns
  def transtions
  end
end
