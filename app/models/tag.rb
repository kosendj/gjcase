class Tag < ActiveRecord::Base
  belongs_to :parent, class_name: 'Tag', foreign_key: :parent_id
  belongs_to :merged_tag, class_name: 'Tag', foreign_key: :merged_to_id

  has_many :tag_assignments
  has_many :images, through: :tag_assignments

  validates :name, presence: true

  before_save do
    if self.parent_id_changed?
      self.parent_id = self.parent.parent_id || self.parent_id
    end
  end
end
