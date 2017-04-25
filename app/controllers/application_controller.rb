class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :user_authentication
  before_action :set_mailer_options
  before_action :set_paper_trail_whodunnit

  attr_accessor :current_user

  helper_method :current_user

  rescue_from 'Redis::CannotConnectError', with: :show_redis_error

  private

  def user_authentication
    return true if @current_user
    if session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
      return true if @current_user
    end
    redirect_to login_url
  end

  def require_admin_user
    if current_user
      if !current_user.is_admin?
        flash[:error] = "Access forbidden"
        redirect_to root_path
        return false
      end
    else
      flash[:error] = "Access forbidden"
      redirect_to login_path
      return false
    end
  end

  def user_for_paper_trail
    if session[:user_id]
      return session[:user_id]
    elsif params["idb_api_token"]
      return params["idb_api_token"]
    elsif request.headers["X-Idb-Api-Token"]
      return request.headers["X-Idb-Api-Token"]
    end

    return
  end

  def trigger_version_change(object, username = "")
    return if object.versions.last.nil?
    VersionChangeWorker.perform_async(object.versions.last.id, username)
  end

  def set_mailer_options
    ActionMailer::Base.default_url_options = {
      :host => IDB.config.mail.host,
      :protocol => IDB.config.mail.protocol
    }
  end

  def show_redis_error(exception)
    render_error(exception, 'It looks like there is a problem with the Redis DB')
  end

  def render_error(exception, message = nil)
    message ||= 'Sorry, something bad happened'

    render 'shared/error', status: 500, locals: {
      exception: exception,
      message: message
    }
  end
end
