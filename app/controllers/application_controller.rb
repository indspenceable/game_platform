class ApplicationController < ActionController::Base
  protect_from_forgery
  SUCCESS_NOTICE_CLASS = "success"
  FAILURE_NOTICE_CLASS = "failure"

  private

  def require_login
    unless @player = logged_in?
      flash[:error] = "log in to access this page"
      redirect_to :controller => :player, :action => :login
    else
      @player.update_attribute(:last_activity, Time.now)
    end
  end

  def logged_in?
    Player.find(session[:player_id]) rescue false
  end

  def flash_success(message)
    flash[:message] = message
    flash[:notice_class] = SUCCESS_NOTICE_CLASS
  end

  def flash_error(message)
    flash[:message] = message
    flash[:notice_class] = FAILURE_NOTICE_CLASS
  end
end
