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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101005015815) do

  create_table "accounts", :force => true do |t|
    t.string   "app_path"
    t.string   "username"
    t.string   "password"
    t.integer  "category_id"
    t.string   "company_id"
    t.string   "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities", :force => true do |t|
    t.string  "name",           :limit => 500
    t.integer "work"
    t.integer "activity_order"
    t.integer "deleted"
    t.integer "category_id"
  end

  create_table "activity_projects", :force => true do |t|
    t.integer  "activity_id"
    t.string   "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string  "name",           :limit => 500
    t.string  "color_code",     :limit => 50
    t.integer "category_order"
  end

  create_table "fact_tags", :id => false, :force => true do |t|
    t.integer "fact_id"
    t.integer "tag_id"
  end

  add_index "fact_tags", ["fact_id"], :name => "idx_fact_tags_fact"
  add_index "fact_tags", ["tag_id"], :name => "idx_fact_tags_tag"

  create_table "facts", :force => true do |t|
    t.integer   "activity_id"
    t.timestamp "start_time"
    t.timestamp "end_time"
    t.string    "description", :limit => nil
  end

# Could not dump table "tags" because of following StandardError
#   Unknown type 'BOOL' for column 'autocomplete'

  create_table "time_entries", :force => true do |t|
    t.integer  "fact_id"
    t.string   "time_entry_id"
    t.string   "todo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "version", :id => false, :force => true do |t|
    t.integer "version"
  end

end
