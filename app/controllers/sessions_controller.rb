class SessionsController < ApplicationController
  skip_before_action :user_authentication, :only => [:new, :create, :destroy]
  layout "login"

  def new
  end

  def create
    BasicUserAuth.new(IDB.config.design.title, self).authenticate(params[:name], params[:password], params[:otp])
    if current_user
      session[:user_id] = current_user.id
      redirect_to root_url
    else
      flash.alert = "Wrong credentials"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url
  end
end
