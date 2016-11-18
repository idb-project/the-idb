class TextileRenderer
  def self.render(string)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, tables: true).render(string).html_safe
  end
end
