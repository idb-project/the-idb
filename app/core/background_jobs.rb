class BackgroundJobs
  def link(name, icon, link)
    %(<a href="#{link}">#{wrap(%(<i class="#{icon}"></i> #{name}</a>))}).html_safe
  end

  private

  def wrap(string)
    if retries?
      %(<span class="text-error"><strong>#{string}</strong></span>)
    else
      string
    end
  end

  def retries?
    Sidekiq::Stats.new.retry_size > 0
  rescue => e
    false
  end
end
