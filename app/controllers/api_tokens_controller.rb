class ApiTokensController < ApplicationController
  before_action :require_admin_user

  def index
    @api_tokens = ApiToken.all
  end

  def new
    @api_token = ApiToken.new
    @api_tokens = {}
    @all_api_tokens = ApiToken.all
  end

  def create
    @api_token = ApiToken.new(params.require(:api_token).permit(:token, :read, :write, :post_logs, :post_reports, :name, :description, :owner_id))
    if @api_token.save
      redirect_to api_tokens_path
    else
      render :new
    end
  end

  def show
    @api_token = ApiToken.find(params[:id])
    @all_api_tokens = ApiToken.all
  end

  def edit
    @api_token = ApiToken.find(params[:id])
    @api_tokens = {}
    @all_api_tokens = ApiToken.all
  end

  def update
    @api_token = ApiToken.find(params[:id])

    if @api_token.update(params.require(:api_token).permit(:token, :read, :write, :post_logs, :post_reports, :name, :description, :owner_id))
      redirect_to api_tokens_path, notice: 'Api Token updated'
    else
      render :edit
    end
  end

  def destroy
    @api_token = ApiToken.find(params[:id])
    @api_token.destroy

    redirect_to api_tokens_path, notice: 'Api Token deleted!'
  end

end
