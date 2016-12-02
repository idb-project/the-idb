class Inventory < ActiveRecord::Base
  acts_as_paranoid

  has_paper_trail

  belongs_to :user
  belongs_to :machine
  belongs_to :owner
  belongs_to :location
  belongs_to :inventory_status
  has_many :attachments, :dependent => :destroy

  scope :unique_name, -> { group(:name) }
  scope :unique_place, -> { group(:place) }
  scope :unique_category, -> { group(:category) }
  scope :unique_seller, -> { group(:seller) }

  validates :purchase_date, format: { with: /\d{4}\-\d{2}\-\d{2}/,
    message: "has to be of format YYYY-MM-DD" }, :allow_blank => true
  validates :warranty_end, format: { with: /\d{4}\-\d{2}\-\d{2}/,
    message: "has to be of format YYYY-MM-DD" }, :allow_blank => true
  validates :install_date, format: { with: /\d{4}\-\d{2}\-\d{2}/,
    message: "has to be of format YYYY-MM-DD" }, :allow_blank => true

  def status_string
    inventory_status.nil? ? "" : inventory_status.name
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end

  def active?
    inventory_status.nil? ? false : !inventory_status.inactive
  end
end
