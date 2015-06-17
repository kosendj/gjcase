class TagAssignment < ActiveRecord::Base
  belongs_to :tag
  belongs_to :image
end
