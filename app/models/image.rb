class Image < ActiveRecord::Base
  validates :source_url, presence: true

  validate do
    if changed_attributes[:source_url]
      errors.add :source_url, 'source_url cannot be updated'
    end
  end

  def image_url
    source_url
  end
end
