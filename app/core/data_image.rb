class DataImage
  def initialize(image, content_type)
    @image = image
    @content_type = content_type
  end

  def to_data_image
    'data:%s;base64,%s' % [@content_type, to_base64(@image)]
  end

  private

  def to_base64(data)
    [data].pack('m').chomp.gsub("\n", '')
  end
end
