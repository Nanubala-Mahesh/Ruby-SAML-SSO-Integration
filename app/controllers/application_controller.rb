# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_action :current_user

  helper :all # include all helpers, all the time
  protect_from_forgery

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password


  protected

  #:nocov:
  def current_user
    user_id = session[:user_id]
    return nil if user_id.blank?
    begin
      @current_user ||= User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      logger.error "Invalid user_id from session: #{user_id}, not matching user found"
    end
    @current_user
  end

  def sign_in_and_redirect(user)
    sessiondata = session.to_hash
    reset_session
    sessiondata.each {|key, val| session[key.to_sym] = val }
    session[:user_id] = user.id
    current_user
    redirect_to root_path and return
  end
  #:nocov:

  def authorize_user!
    unless @current_user
      flash[:alert] = 'You need to be logged in to proceed!'
      if request.xhr?
        render js: %(location.reload();)
      else
        redirect_to root_url
      end
    end
  end

  # protected

  # def current_user=(user)
  #   session[:user] = user.id
  # end

  # def current_user
  #   User.find(session[:user].to_i) if session[:user]
  # end
  # helper_method :current_user

  # def authenticate
  #   unless current_user
  #     session[:redirect_to] = request.url
  #     settings = SamlController.get_saml_settings
  #     saml_request = Onelogin::Saml::Authrequest.new
  #     redirect_to(saml_request.create(settings))
  #   end
  # end
end
