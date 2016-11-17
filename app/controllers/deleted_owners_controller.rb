class DeletedOwnersController < ApplicationController
  def index
    @deleted_owners = Owner.unscope(where: :deleted_at).where.not(deleted_at: nil)
  end

  def edit
    @owner = Owner.unscope(where: :deleted_at).find(params[:id])
    @owner.restore(:recursive => true)

    render "owners/show"
  end

  def destroy
    @owner = Owner.unscope(where: :deleted_at).find(params[:id])
    @owner.really_destroy!

    @deleted_owners = Owner.unscope(where: :deleted_at).where.not(deleted_at: nil)
    render "index"
  end
end
