
class ApiTokenPresenter < Keynote::Presenter
  presents :api_token

  delegate :id, :token, :read, :write, :name, :description,
           to: :api_token

  def token_link
    link_to(api_token.token, api_token)
  end

end
