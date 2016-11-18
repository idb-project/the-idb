class MarkupController < ApplicationController
  def do_render
    render text: TextileRenderer.render(request.body.read)
  end
end
