class Image < ActiveRecord::Base
  include Garage::Representer

  validates :source_url, presence: true

  has_many :tag_assignments
  has_many :tags, through: :tag_assignments

  property :id
  property :comment
  property :image_url
  collection :tags, selectable: true

  validate do
    if changed_attributes[:source_url]
      errors.add :source_url, 'source_url cannot be updated'
    end
  end

  scope :unduplicated, -> { where(duplication_id: nil) }

  def image_url
    source_url
  end
end
