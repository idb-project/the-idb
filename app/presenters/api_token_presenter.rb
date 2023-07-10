
class ApiTokenPresenter < Keynote::Presenter
  presents :api_token

  delegate :id, :token, :read, :write, :post_logs, :post_reports, :name, :description, :owner,
           to: :api_token

  def token_link
    link_to(api_token.token, api_token)
  end

end
