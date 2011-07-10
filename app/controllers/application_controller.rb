class ApplicationController < ActionController::Base
  protect_from_forgery
  SUCCESS_NOTICE_CLASS = "success"
  FAILURE_NOTICE_CLASS = "failure"

  private

  def require_login
    unless logged_in?
      flash[:error] = "log in to access this page"
      redirect_to :controller => :player, :action => :login
    end
  end

  def logged_in?
    !!session[:player_id]
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
