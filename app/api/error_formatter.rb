module ErrorFormatter
  def self.call message, backtrace, options, env
    { :response_type => 'error', :response => message }.to_json
  end
end
