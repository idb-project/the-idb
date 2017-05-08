class SwitchPort < ActiveRecord::Base
  ICINGA_REGEX = /^port(\d+)-(\S+)-(#{Nic::MAC_REGEX})$/i

  belongs_to :nic
  belongs_to :switch

  validates :number, :nic_id, :switch_id, presence: true
end
