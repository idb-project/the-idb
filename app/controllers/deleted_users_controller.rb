class DeletedUsersController < ApplicationController
  def index
    @deleted_users = User.unscope(where: :deleted_at).where.not(deleted_at: nil)
  end

  def edit
    @user = User.unscope(where: :deleted_at).find(params[:id])
    @user.restore(:recursive => true)

    redirect_to users_path
  end
end
