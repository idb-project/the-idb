class FlashPresenter < Keynote::Presenter
  presents :flash

  def show
    build_html do
      flash.each do |type, message|
        div class: alert_class(type) do
          button.close '&times;'.html_safe, 'data-dismiss' => 'alert'
          div message
        end
      end
    end
  end

  private

  def alert_class(type)
    case type
    when :notice
      'alert alert-info'
    when :success
      'alert alert-success'
    when :error, :alert
      'alert alert-error'
    else
      'alert alert-success'
    end
  end
end
