module IDB
  begin
    VERSION = File.open("#{Rails.root}/revision.txt").read.strip.to_s
  rescue => ex
    Rails.logger.error ex.message
    VERSION = '1.7.0'
  end
end
