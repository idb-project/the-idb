class ForeignApi
  GenericError = Class.new(StandardError)
  ConnectionError = Class.new(GenericError)
  TimeoutError = Class.new(GenericError)
  TIMEOUT = 5

  def initialize(url, verify_ssl = true)
    @url = url
    Excon.defaults[:ssl_verify_peer] = verify_ssl
    @http = Excon.new(url, tcp_nodelay: true, connect_timeout: TIMEOUT)
  end

  def get(path, query = {}, headers = {})
    request(:get, path: path, query: query, headers: headers)
  end

  def post(path, body, headers = {})
    request(:post, path: path, body: JSON.dump(body), headers: {
      'Content-Type' => 'application/json'
    }.merge(headers))
  end

  private

  def request(method, options)
    ForeignResponse.new(@http.request({method: method}.merge(options)))
  rescue Excon::Errors::SocketError => e
    raise ConnectionError, "Unable to connect to API at #{@http.params[:hostname]}: #{e.message}"
  rescue Excon::Errors::Timeout => e
    raise TimeoutError, "Connection timeout at #{@http.params[:hostname]}: #{e.message} (#{TIMEOUT}s)"
  rescue Excon::Errors::Error => e
    raise GenericError, "Error during API request to #{@http.params[:hostname]}: #{e.message}"
  end
end
