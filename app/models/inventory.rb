class Inventory < ActiveRecord::Base
  acts_as_paranoid

  has_paper_trail

  belongs_to :user
  belongs_to :machine
  belongs_to :owner
  belongs_to :location
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

  Status = {
    0 => 'active',
    1 => 'broken',
    2 => 'sold'
  }.freeze

  def status_string
    Status.fetch(status, '')
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end

  def active?
    status == 0
  end
end
