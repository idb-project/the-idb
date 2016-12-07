class MarkupController < ApplicationController
  def do_render
    render plain: TextileRenderer.render(request.body.read)
  end
end
