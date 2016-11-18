class IpAddress < ActiveRecord::Base
  belongs_to :nic

  def machine
    nic.machine
  end
end
