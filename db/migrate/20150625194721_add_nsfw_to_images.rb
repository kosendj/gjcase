class AddNsfwToImages < ActiveRecord::Migration
  def change
    add_column :images, :nsfw, :boolean
  end
end
