require 'uri'
require 'net/http'

module HttpHelper
  def self.req(url, method = "get")
    url = URI(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = url.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 5
    #http.set_debug_output $stderr

    request = case method
      when "get" then Net::HTTP::Get.new(url)
      when "post" then Net::HTTP::Post.new(url)
      when "put" then Net::HTTP::Put.new(url)
      when "delete" then Net::HTTP::Delete.new(url)
      when "patch" then Net::HTTP::Patch.new(url)
    end
    request["content-type"] = 'application/json'
    request["user-agent"] = IDB.config.design.title

    begin
      response = http.request(request)
    rescue Exception
      raise
    end
  end
end
