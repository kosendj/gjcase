class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :source_url
      t.text :comment
      t.string :storage_path
      t.string :sha
      t.integer :duplication_id

      t.timestamps null: false
    end
  end
end
