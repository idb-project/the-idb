class ForeignResponse < Struct.new(:response)
  def body
    response.body
  end

  def data
    if response.headers['Content-Type'] =~ %r(application/json)
      JSON.parse(body)
    else
      nil
    end
  end

  def code
    response.status
  end

  def success?
    (200..299).include?(code)
  end

  def error?
    !success?
  end
end
