class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to users_path, notice: 'User updated'
    else
      render :show
    end
  end

  def destroy
    @user = User.find(params[:id])
    username = @user.name
    @user.destroy
    UserDeleteWorker.perform_async(username, current_user.display_name)
    @users = User.all
    render json: {success: true, redirectTo: users_path}, notice: 'DELETED'
  end

  private

  def user_params
    params.require(:user).permit({owner_ids: []})
  end
end
