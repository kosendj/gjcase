class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :alt_name
      t.references :merged_to
      t.references :parent

      t.timestamps null: false
    end
  end
end
