module ErrorFormatter
  def self.call message, backtrace, options, env, original_exception
    { :response_type => 'error', :response => message }.to_json
  end
end
