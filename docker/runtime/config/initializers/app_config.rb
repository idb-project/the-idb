module IDB
  def self.config(data = nil)
    if data
      data.each do |key, value|
        config_add(InfrastructureDb::Application.config.app, key, value)
      end
    else
      InfrastructureDb::Application.config.app
    end
  end

  def self.config_add(cfg, key, value)
    case value
    when Hash
      value.each do |k, v|
        cfg[key] ||= ActiveSupport::OrderedOptions.new
        config_add(cfg[key], k, v)
      end
    else
      cfg.send("#{key}=", value)
    end
  end
end

InfrastructureDb::Application.config.app = ActiveSupport::OrderedOptions.new

IDB.config(YAML.load(ERB.new(File.read(Rails.root.join('config/application.yml'))).result)[Rails.env])

