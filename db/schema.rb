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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120214042141) do

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id",                   :null => false
    t.string   "auditable_type",                 :null => false
    t.integer  "owner_id",                       :null => false
    t.string   "owner_type",                     :null => false
    t.integer  "user_id",                        :null => false
    t.string   "user_type",                      :null => false
    t.string   "action",                         :null => false
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.text     "comment"
    t.datetime "created_at",                     :null => false
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
  end

  add_index "authentications", ["uid"], :name => "index_authentications_on_uid"
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "comissions", :force => true do |t|
    t.string   "number"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "kind"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "device_messages", :force => true do |t|
    t.text     "message"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_messages", ["user_id"], :name => "index_device_messages_on_user_id"

  create_table "organizations", :force => true do |t|
    t.string   "title"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_locations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "comission_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_locations", ["user_id", "comission_id"], :name => "index_user_locations_on_user_id_and_comission_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "watcher_status"
    t.integer  "organization_id"
    t.boolean  "is_watcher"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.string   "phone"
    t.text     "urls"
    t.date     "birth_date"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["is_watcher", "watcher_status"], :name => "index_users_on_is_watcher_and_watcher_status"
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "watcher_referals", :force => true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.string   "watcher_referal_image"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
  end

  add_index "watcher_referals", ["status"], :name => "index_watcher_referals_on_status"
  add_index "watcher_referals", ["user_id"], :name => "index_watcher_referals_on_user_id"

  create_table "watcher_reports", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "recorded_at"
    t.boolean  "is_violation"
    t.integer  "user_id"
    t.integer  "comission_id"
    t.integer  "device_message_id"
    t.string   "image"
    t.string   "video_path"
    t.string   "status"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "watcher_reports", ["comission_id"], :name => "index_watcher_logs_on_comission_id"
  add_index "watcher_reports", ["device_message_id"], :name => "index_watcher_logs_on_device_message_id"
  add_index "watcher_reports", ["user_id"], :name => "index_watcher_logs_on_user_id"

end
