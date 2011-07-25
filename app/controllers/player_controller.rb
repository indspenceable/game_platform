class PlayerController < ApplicationController

  def register
  end

  #posted to from the register page
  def create_player
    if Player.find_by_name params[:name]
      flash_error "That name is already in use!"
      return redirect_to :back
    end
    Player.create_player(params[:name],params[:email], params[:password])
    session[:player_id] = Player.authenticate(params[:name],params[:password]).id rescue nil
    flash_success "registered successfully"
    redirect_to lobby_path
  end

  def login
    if request.post?
      if session[:player_id] = Player.authenticate(params[:name],params[:password]).id rescue nil
        puts "Session contains #{session.inspect}"
        flash_success "Successfully logged in"
        redirect_to lobby_path
      else
        flash_error "Wrong username/pass"
        redirect_to :back
      end
    end
  end
end
