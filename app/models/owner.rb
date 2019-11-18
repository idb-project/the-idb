class Owner < ActiveRecord::Base
  serialize :data

  acts_as_paranoid if IDB.config.modules.softdelete

  has_paper_trail

  has_many :inventories, :dependent => :destroy
  has_many :machines, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_many :cloud_providers, :dependent => :destroy
  has_many :api_tokens, :dependent => :destroy
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

  def announcement_contact
    self[:announcement_contact].blank? ? "" : self[:announcement_contact].delete(" ").gsub(";", ",")
  end

  def announcement_contact=(contact)
    self[:announcement_contact] = contact.blank? ? "" : contact.delete(" ").gsub(";", ",")
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      -> { where(deleted_at: nil) }
    else
      -> { where(deleted_at: nil).joins(:users).where(users: { id: User.current }) }
    end
  end

  def self.default_owner
    owner = nil

    if IDB.config.default_owner
      begin
        owner = Owner.find(IDB.config.default_owner)
      rescue ActiveRecord::RecordNotFound => e
      end
    end

    unless owner
      if Owner.all.size == 0
        owner = Owner.create(name: "default", nickname: "default")
      end
      owner = Owner.first unless owner
    end

    owner
  end
end
