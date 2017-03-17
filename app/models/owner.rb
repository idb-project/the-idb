class Owner < ActiveRecord::Base
  serialize :data

  acts_as_paranoid if IDB.config.modules.softdelete

  has_paper_trail

  has_many :inventories, :dependent => :destroy
  has_many :machines, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_many :cloud_providers, :dependent => :destroy
  has_and_belongs_to_many :users

  validates :name, :nickname, presence: true
  validates :name, :nickname, uniqueness: true

  # Make sure we have a hash in #data
  after_initialize { self.data ||= {} }

  def self.eager_find(id)
    includes(:cloud_providers, :machines, machines: [{nics: [:ip_address]}, :owner]).find(id)
  end

  def display_name
    nickname || name
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end
end
