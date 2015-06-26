# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150625194721) do

  create_table "images", force: :cascade do |t|
    t.string   "source_url",        limit: 255
    t.text     "comment",           limit: 16777215
    t.string   "storage_path",      limit: 255
    t.string   "sha",               limit: 255
    t.integer  "duplication_id",    limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "source_identifier", limit: 255
    t.boolean  "nsfw",              limit: 1
  end

  add_index "images", ["source_identifier"], name: "index_images_on_source_identifier", length: {"source_identifier"=>191}, using: :btree

  create_table "tag_assignments", force: :cascade do |t|
    t.integer  "tag_id",     limit: 4
    t.integer  "image_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "tag_assignments", ["image_id"], name: "index_tag_assignments_on_image_id", using: :btree
  add_index "tag_assignments", ["tag_id"], name: "index_tag_assignments_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "alt_name",     limit: 255
    t.integer  "merged_to_id", limit: 4
    t.integer  "parent_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_foreign_key "tag_assignments", "images"
  add_foreign_key "tag_assignments", "tags"
end
