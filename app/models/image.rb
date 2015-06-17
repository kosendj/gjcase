class Image < ActiveRecord::Base
  validates :source_url, presence: true

  has_many :tag_assignments
  has_many :tags, through: :tag_assignments

  validate do
    if changed_attributes[:source_url]
      errors.add :source_url, 'source_url cannot be updated'
    end
  end

  def image_url
    source_url
  end
end
