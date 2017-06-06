class ApiTokenPresenter < Keynote::Presenter
  presents :api_token

  delegate :id, :token, :read, :write, :name, :description,
           to: :api_token

  def token_link
    link_to(api_token.token, api_token)
  end

  def owners
    list = '<ul>'
    api_token.owners.each do |o|
      o = k(:owner, o)
      list += "<li>#{o.name_link}</li>"
    end
    list += '</ul>'
    list.html_safe
  end

end