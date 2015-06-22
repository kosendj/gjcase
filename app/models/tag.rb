class Tag < ActiveRecord::Base
  include Garage::Representer 

  property :name
  property :alt_name

  property :merged_tag, selectable: true
  collection :aliases, selectable: true

  property :parent, selectable: true
  collection :children, selectable: true

  link(:parent) { self.parent && api_tag_path(self.parent) }
  link(:merged_tag) { self.merged_tag && api_tag_path(self.merged_tag) }
  link(:self) { api_tag_path(self) }

  belongs_to :parent, class_name: 'Tag', foreign_key: :parent_id
  has_many :children, class_name: 'Tag', foreign_key: :parent_id

  belongs_to :merged_tag, class_name: 'Tag', foreign_key: :merged_to_id
  has_many :aliases, class_name: 'Tag', foreign_key: :merged_to_id

  has_many :tag_assignments
  has_many :images, through: :tag_assignments


  validates :name, presence: true, uniqueness: true

  validate :validate_not_merged_with_itself
  validate :validate_parent_is_not_itself

  scope :active, -> { where(merged_to_id: nil) }

  def self.search(query)
    tag = if query.to_s =~ /\A[0-9]+\z/
      self.find_by_id(query) || self.find_by_name(query)
    else
      self.find_by_name(query)
    end

    tag.try(:merged_tag) || tag
  end

  def self.search!(query)
    search(query) or raise ActiveRecord::RecordNotFound
  end

  before_save do
    if self.parent_id_changed?
      self.parent_id = self.parent.parent_id || self.parent_id
    end
  end

  def merge_to!(other)
    target = other.merged_tag || other

    self.merged_tag = target
    self.save!

    self.tag_assignments.update_all(tag_id: target.id)

    nil
  end

  private

  def validate_not_merged_with_itself
    if self.merged_to_id && self.merged_to_id == self.id
      errors.add(:merged_to_id, "can't be itself")
    end
  end

  def validate_parent_is_not_itself
    if self.parent_id && self.parent_id == self.id
      errors.add(:parent_id, "can't be itself")
    end
  end
end
