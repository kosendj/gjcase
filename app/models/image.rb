class Image < ActiveRecord::Base
  include Garage::Representer

  validates :source_url, presence: true

  has_many :tag_assignments
  has_many :tags, through: :tag_assignments

  property :id
  property :comment
  property :image_url
  collection :tags, selectable: true

  link(:tags) { api_image_image_tags_path(self) }

  validate do
    if changed_attributes[:source_url]
      errors.add :source_url, 'source_url cannot be updated'
    end
  end

  scope :unduplicated, -> { where(duplication_id: nil) }

  def real_image_url
    if self.storage_path && Rails.application.secrets.storage_url
      "#{Rails.application.secrets.storage_url}/#{self.storage_path}"
    else
      source_url
    end
  end

  def image_url
    if Rails.application.secrets.camo
      Camo.new(Rails.application.secrets.camo, Rails.application.secrets.camo_url).url(real_image_url)
    else
      real_image_url
    end
  end

  def extension
    url_ext = File.extname(URI(source_url).path) rescue ''
    url_ext.empty? ? 'gif' : url_ext
  end

  def set_storage_path!
    self.storage_path = "v1/#{self.sha[-2, 2] || ?_}/#{self.sha[-4, 2] || ?_}/#{self.sha}.#{self.extension}"
  end
end
