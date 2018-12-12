class TextileRenderer
  def self.render(string)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, {tables: true, fenced_code_blocks: true, lax_spacing: true}).render(string).html_safe
  end
end
