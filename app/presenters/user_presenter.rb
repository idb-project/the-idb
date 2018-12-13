class UserPresenter < Keynote::Presenter
  use_html_5_tags

  presents :user

  delegate :email, :login, to: :user

  def name_link
    link_to(user.name ? user.name : "-no name-", user_path(user)) if user
  end

  def admin
    if user.admin
      return "yes"
    end

    "no"
  end

end
