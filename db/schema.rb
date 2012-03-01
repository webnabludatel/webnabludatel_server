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

ActiveRecord::Schema.define(:version => 20120301004353) do

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

  create_table "check_list_items", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "order"
    t.string   "lo_value"
    t.string   "hi_value"
    t.string   "lo_text"
    t.string   "hi_text"
    t.string   "ancestry"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "control_type"
  end

  create_table "commissions", :force => true do |t|
    t.string   "number"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "kind"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "region_id"
    t.boolean  "is_system",  :default => false
  end

  add_index "commissions", ["region_id"], :name => "index_commissions_on_region_id"

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
    t.text     "payload"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",            :default => "message", :null => false
    t.string   "device_id"
    t.integer  "media_item_id"
    t.integer  "user_message_id"
  end

  add_index "device_messages", ["media_item_id"], :name => "index_device_messages_on_media_item_id"
  add_index "device_messages", ["user_id"], :name => "index_device_messages_on_user_id"
  add_index "device_messages", ["user_message_id"], :name => "index_device_messages_on_user_message_id"

  create_table "media_items", :force => true do |t|
    t.integer  "user_message_id"
    t.string   "url"
    t.string   "media_type"
    t.datetime "timestamp"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "deleted",         :default => true, :null => false
    t.integer  "user_id"
  end

  add_index "media_items", ["user_id"], :name => "index_media_items_on_user_id"
  add_index "media_items", ["user_message_id"], :name => "index_media_items_on_user_message_id"

  create_table "organizations", :force => true do |t|
    t.string   "title"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referral_photos", :force => true do |t|
    t.integer  "watcher_referral_id"
    t.integer  "media_item_id"
    t.string   "image"
    t.datetime "timestamp"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "referral_photos", ["watcher_referral_id"], :name => "index_referral_photos_on_watcher_referral_id"

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.string   "external_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "position"
  end

  create_table "sos_message_photos", :force => true do |t|
    t.integer  "sos_message_id"
    t.string   "image"
    t.datetime "timestamp"
    t.integer  "media_item_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "sos_message_photos", ["sos_message_id"], :name => "index_sos_message_photos_on_sos_message_id"

  create_table "sos_messages", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "timestamp"
    t.decimal  "latitude",         :precision => 11, :scale => 8
    t.decimal  "longitude",        :precision => 11, :scale => 8
    t.integer  "user_message_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "user_location_id"
  end

  add_index "sos_messages", ["user_id"], :name => "index_sos_messages_on_user_id"
  add_index "sos_messages", ["user_location_id"], :name => "index_sos_messages_on_user_location_id"

  create_table "splash_subscribers", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_location_photos", :force => true do |t|
    t.integer  "user_location_id"
    t.integer  "media_item_id"
    t.string   "image"
    t.datetime "timestamp"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "user_location_photos", ["user_location_id"], :name => "index_user_location_photos_on_user_location_id"

  create_table "user_locations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commission_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_id"
    t.string   "chairman"
    t.string   "secretary"
  end

  add_index "user_locations", ["user_id", "commission_id"], :name => "index_user_locations_on_user_id_and_comission_id"

  create_table "user_messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.string   "value"
    t.decimal  "latitude",                  :precision => 11, :scale => 8
    t.decimal  "longitude",                 :precision => 11, :scale => 8
    t.datetime "timestamp"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "polling_place_region"
    t.string   "polling_place_id"
    t.string   "internal_id"
    t.string   "polling_place_internal_id"
    t.integer  "user_location_id"
    t.integer  "watcher_report_id"
  end

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
    t.string   "middle_name"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["is_watcher", "watcher_status"], :name => "index_users_on_is_watcher_and_watcher_status"
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "watcher_attributes", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "order"
    t.string   "lo_value"
    t.string   "hi_value"
    t.string   "lo_text"
    t.string   "hi_text"
    t.string   "ancestry"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "watcher_referrals", :force => true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
  end

  add_index "watcher_referrals", ["status"], :name => "index_watcher_referals_on_status"
  add_index "watcher_referrals", ["user_id"], :name => "index_watcher_referals_on_user_id"

  create_table "watcher_reports", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "timestamp"
    t.boolean  "is_violation"
    t.integer  "user_id"
    t.string   "image"
    t.string   "video_path"
    t.string   "status"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "check_list_item_id"
    t.integer  "user_location_id"
    t.decimal  "latitude",           :precision => 11, :scale => 8
    t.decimal  "longitude",          :precision => 11, :scale => 8
  end

  add_index "watcher_reports", ["check_list_item_id"], :name => "index_watcher_reports_on_watcher_checklist_item_id"
  add_index "watcher_reports", ["timestamp"], :name => "index_watcher_reports_on_timestamp"
  add_index "watcher_reports", ["user_id"], :name => "index_watcher_reports_on_user_id"
  add_index "watcher_reports", ["user_location_id"], :name => "index_watcher_reports_on_user_location_id"

end
