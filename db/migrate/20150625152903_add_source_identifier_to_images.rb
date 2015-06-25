class AddSourceIdentifierToImages < ActiveRecord::Migration
  def change
    add_column :images, :source_identifier, :string
    add_index :images, :source_identifier
  end
end
