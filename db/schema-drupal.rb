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

ActiveRecord::Schema.define(:version => 0) do

  create_table "access", :primary_key => "aid", :force => true do |t|
    t.string  "mask",                :default => "", :null => false
    t.string  "type",                :default => "", :null => false
    t.integer "status", :limit => 1, :default => 0,  :null => false
  end

  create_table "accesslog", :primary_key => "aid", :force => true do |t|
    t.string  "sid",       :limit => 64,  :default => "", :null => false
    t.string  "title"
    t.string  "path"
    t.text    "url"
    t.string  "hostname",  :limit => 128
    t.integer "uid",                      :default => 0
    t.integer "timer",                    :default => 0,  :null => false
    t.integer "timestamp",                :default => 0,  :null => false
  end

  add_index "accesslog", ["timestamp"], :name => "accesslog_timestamp"
  add_index "accesslog", ["uid"], :name => "uid"

  create_table "actions", :primary_key => "aid", :force => true do |t|
    t.string "type",        :limit => 32,         :default => "",  :null => false
    t.string "callback",                          :default => "",  :null => false
    t.text   "parameters",  :limit => 2147483647,                  :null => false
    t.string "description",                       :default => "0", :null => false
  end

  create_table "actions_aid", :primary_key => "aid", :force => true do |t|
  end

  create_table "activity", :primary_key => "aid", :force => true do |t|
    t.integer "uid",                                       :null => false
    t.string  "op",         :limit => 50,                  :null => false
    t.string  "type",       :limit => 50,                  :null => false
    t.integer "nid"
    t.integer "eid"
    t.integer "created",                                   :null => false
    t.string  "actions_id",               :default => "0", :null => false
    t.integer "status",     :limit => 1,  :default => 1
  end

  add_index "activity", ["actions_id"], :name => "actions_id"
  add_index "activity", ["created"], :name => "created"
  add_index "activity", ["eid"], :name => "eid"
  add_index "activity", ["nid"], :name => "nid"

  create_table "activity_access", :id => false, :force => true do |t|
    t.integer "aid",                  :null => false
    t.string  "realm",                :null => false
    t.integer "value", :default => 0, :null => false
  end

  create_table "activity_comments", :primary_key => "cid", :force => true do |t|
    t.integer "aid",       :default => 0,  :null => false
    t.integer "uid",       :default => 0,  :null => false
    t.string  "comment",   :default => "", :null => false
    t.integer "timestamp", :default => 0,  :null => false
  end

  add_index "activity_comments", ["timestamp"], :name => "timestamp"

  create_table "activity_comments_stats", :primary_key => "aid", :force => true do |t|
    t.integer "changed",       :default => 0, :null => false
    t.integer "comment_count", :default => 0, :null => false
  end

  add_index "activity_comments_stats", ["changed"], :name => "changed"

  create_table "activity_messages", :primary_key => "amid", :force => true do |t|
    t.text "message", :limit => 2147483647, :null => false
  end

  create_table "activity_targets", :id => false, :force => true do |t|
    t.integer "aid",                                   :null => false
    t.integer "uid",                    :default => 0, :null => false
    t.integer "amid",                   :default => 0, :null => false
    t.string  "language", :limit => 12,                :null => false
  end

  add_index "activity_targets", ["amid"], :name => "amid", :unique => true

  create_table "advanced_help_index", :primary_key => "sid", :force => true do |t|
    t.string "module",                 :default => "", :null => false
    t.string "topic",                  :default => "", :null => false
    t.string "language", :limit => 12, :default => "", :null => false
  end

  add_index "advanced_help_index", ["language"], :name => "language"

  create_table "aggregator_category", :primary_key => "cid", :force => true do |t|
    t.string  "title",                             :default => "", :null => false
    t.text    "description", :limit => 2147483647,                 :null => false
    t.integer "block",       :limit => 1,          :default => 0,  :null => false
  end

  add_index "aggregator_category", ["title"], :name => "title", :unique => true

  create_table "aggregator_category_feed", :id => false, :force => true do |t|
    t.integer "fid", :default => 0, :null => false
    t.integer "cid", :default => 0, :null => false
  end

  add_index "aggregator_category_feed", ["fid"], :name => "fid"

  create_table "aggregator_category_item", :id => false, :force => true do |t|
    t.integer "iid", :default => 0, :null => false
    t.integer "cid", :default => 0, :null => false
  end

  add_index "aggregator_category_item", ["iid"], :name => "iid"

  create_table "aggregator_feed", :primary_key => "fid", :force => true do |t|
    t.string  "title",                             :default => "", :null => false
    t.string  "url",                               :default => "", :null => false
    t.integer "refresh",                           :default => 0,  :null => false
    t.integer "checked",                           :default => 0,  :null => false
    t.string  "link",                              :default => "", :null => false
    t.text    "description", :limit => 2147483647,                 :null => false
    t.text    "image",       :limit => 2147483647,                 :null => false
    t.string  "etag",                              :default => "", :null => false
    t.integer "modified",                          :default => 0,  :null => false
    t.integer "block",       :limit => 1,          :default => 0,  :null => false
  end

  add_index "aggregator_feed", ["title"], :name => "title", :unique => true
  add_index "aggregator_feed", ["url"], :name => "url", :unique => true

  create_table "aggregator_item", :primary_key => "iid", :force => true do |t|
    t.integer "fid",                               :default => 0,  :null => false
    t.string  "title",                             :default => "", :null => false
    t.string  "link",                              :default => "", :null => false
    t.string  "author",                            :default => "", :null => false
    t.text    "description", :limit => 2147483647,                 :null => false
    t.integer "timestamp"
    t.string  "guid"
  end

  add_index "aggregator_item", ["fid"], :name => "fid"

  create_table "antispam_counter", :force => true do |t|
    t.datetime "date",                          :null => false
    t.integer  "provider",       :default => 0, :null => false
    t.integer  "spam_detected",  :default => 0
    t.integer  "ham_detected",   :default => 0
    t.integer  "false_negative", :default => 0
    t.integer  "false_positive", :default => 0
  end

  create_table "antispam_moderator", :primary_key => "uid", :force => true do |t|
    t.string "email_for", :limit => 20, :default => "", :null => false
  end

  add_index "antispam_moderator", ["email_for"], :name => "email_for"

  create_table "antispam_spam_marks", :id => false, :force => true do |t|
    t.string  "content_type", :limit => 20,  :default => "",  :null => false
    t.integer "content_id",                  :default => 0,   :null => false
    t.integer "spam_created",                :default => 0,   :null => false
    t.string  "hostname",     :limit => 128, :default => "",  :null => false
    t.string  "mail",         :limit => 128, :default => "",  :null => false
    t.string  "signature",    :limit => 40,  :default => ""
    t.float   "spaminess",                   :default => 1.0
    t.string  "judge",        :limit => 40,  :default => ""
  end

  add_index "antispam_spam_marks", ["hostname"], :name => "hostname"
  add_index "antispam_spam_marks", ["mail"], :name => "mail"
  add_index "antispam_spam_marks", ["spam_created"], :name => "spam_created"

  create_table "authmap", :primary_key => "aid", :force => true do |t|
    t.integer "uid",                     :default => 0,  :null => false
    t.string  "authname", :limit => 128, :default => "", :null => false
    t.string  "module",   :limit => 128, :default => "", :null => false
  end

  add_index "authmap", ["authname"], :name => "authname", :unique => true

  create_table "autoload_registry", :id => false, :force => true do |t|
    t.string  "name",                  :default => "", :null => false
    t.string  "type",     :limit => 9, :default => "", :null => false
    t.string  "filename",                              :null => false
    t.string  "module",                :default => "", :null => false
    t.integer "weight",                :default => 0,  :null => false
  end

  add_index "autoload_registry", ["type", "weight", "module"], :name => "hook"

  create_table "autoload_registry_file", :primary_key => "filename", :force => true do |t|
    t.string "hash", :limit => 64, :null => false
  end

  create_table "backup_migrate_destinations", :primary_key => "destination_id", :force => true do |t|
    t.string "name",                   :null => false
    t.string "type",     :limit => 32, :null => false
    t.text   "location",               :null => false
    t.text   "settings",               :null => false
  end

  create_table "backup_migrate_profiles", :primary_key => "profile_id", :force => true do |t|
    t.string  "name",                                          :null => false
    t.string  "filename",         :limit => 50,                :null => false
    t.integer "append_timestamp", :limit => 1,  :default => 0, :null => false
    t.string  "timestamp_format", :limit => 14,                :null => false
    t.text    "filters",                                       :null => false
  end

  create_table "backup_migrate_schedules", :primary_key => "schedule_id", :force => true do |t|
    t.string  "name",                                           :null => false
    t.string  "source_id",      :limit => 32, :default => "db", :null => false
    t.string  "destination_id", :limit => 32, :default => "0",  :null => false
    t.string  "profile_id",     :limit => 32, :default => "0",  :null => false
    t.integer "keep",                         :default => 0,    :null => false
    t.integer "period",                       :default => 0,    :null => false
    t.integer "last_run",                     :default => 0,    :null => false
    t.integer "enabled",        :limit => 1,  :default => 0,    :null => false
    t.integer "cron",           :limit => 1,  :default => 0,    :null => false
  end

  create_table "batch", :primary_key => "bid", :force => true do |t|
    t.string  "token",     :limit => 64,         :null => false
    t.integer "timestamp",                       :null => false
    t.text    "batch",     :limit => 2147483647
  end

  add_index "batch", ["token"], :name => "token"

  create_table "blocks", :primary_key => "bid", :force => true do |t|
    t.string  "module",     :limit => 64, :default => "",  :null => false
    t.string  "delta",      :limit => 32, :default => "0", :null => false
    t.string  "theme",      :limit => 64, :default => "",  :null => false
    t.integer "status",     :limit => 1,  :default => 0,   :null => false
    t.integer "weight",     :limit => 1,  :default => 0,   :null => false
    t.string  "region",     :limit => 64, :default => "",  :null => false
    t.integer "custom",     :limit => 1,  :default => 0,   :null => false
    t.integer "throttle",   :limit => 1,  :default => 0,   :null => false
    t.integer "visibility", :limit => 1,  :default => 0,   :null => false
    t.text    "pages",                                     :null => false
    t.string  "title",      :limit => 64, :default => "",  :null => false
    t.integer "cache",      :limit => 1,  :default => 1,   :null => false
  end

  add_index "blocks", ["theme", "module", "delta"], :name => "tmd", :unique => true
  add_index "blocks", ["theme", "status", "region", "weight", "module"], :name => "list"

  create_table "blocks_roles", :id => false, :force => true do |t|
    t.string  "module", :limit => 64, :null => false
    t.string  "delta",  :limit => 32, :null => false
    t.integer "rid",                  :null => false
  end

  add_index "blocks_roles", ["rid"], :name => "rid"

  create_table "book", :primary_key => "mlid", :force => true do |t|
    t.integer "nid", :default => 0, :null => false
    t.integer "bid", :default => 0, :null => false
  end

  add_index "book", ["bid"], :name => "bid"
  add_index "book", ["nid"], :name => "nid", :unique => true

  create_table "boost_cache", :primary_key => "hash", :force => true do |t|
    t.text    "filename",                                      :null => false
    t.string  "base_dir",      :limit => 128, :default => "",  :null => false
    t.integer "expire",                       :default => 0,   :null => false
    t.integer "lifetime",                     :default => -1,  :null => false
    t.integer "push",          :limit => 2,   :default => -1,  :null => false
    t.string  "page_callback",                :default => "",  :null => false
    t.string  "page_type",                    :default => "",  :null => false
    t.string  "page_id",       :limit => 64,  :default => "",  :null => false
    t.string  "extension",     :limit => 8,   :default => "",  :null => false
    t.integer "timer",                        :default => 0,   :null => false
    t.float   "timer_average",                :default => 0.0, :null => false
    t.string  "hash_url",      :limit => 32,  :default => "",  :null => false
    t.text    "url",                                           :null => false
  end

  add_index "boost_cache", ["base_dir"], :name => "base_dir"
  add_index "boost_cache", ["expire"], :name => "expire"
  add_index "boost_cache", ["extension"], :name => "extension"
  add_index "boost_cache", ["page_callback"], :name => "page_callback"
  add_index "boost_cache", ["page_id"], :name => "page_id"
  add_index "boost_cache", ["page_type"], :name => "page_type"
  add_index "boost_cache", ["push"], :name => "push"
  add_index "boost_cache", ["timer"], :name => "timer"
  add_index "boost_cache", ["timer_average"], :name => "timer_average"

  create_table "boost_cache_relationships", :primary_key => "hash", :force => true do |t|
    t.string  "base_dir",            :limit => 128, :default => "",  :null => false
    t.string  "page_callback",                      :default => "",  :null => false
    t.string  "page_type",                          :default => "0", :null => false
    t.string  "page_id",             :limit => 64,  :default => "",  :null => false
    t.string  "child_page_callback",                :default => "",  :null => false
    t.string  "child_page_type",                    :default => "0", :null => false
    t.string  "child_page_id",       :limit => 64,  :default => "",  :null => false
    t.string  "hash_url",            :limit => 32,  :default => "",  :null => false
    t.integer "timestamp",                          :default => 0,   :null => false
  end

  add_index "boost_cache_relationships", ["base_dir"], :name => "base_dir"
  add_index "boost_cache_relationships", ["child_page_callback"], :name => "child_page_callback"
  add_index "boost_cache_relationships", ["child_page_id"], :name => "child_page_id"
  add_index "boost_cache_relationships", ["child_page_type"], :name => "child_page_type"
  add_index "boost_cache_relationships", ["hash_url"], :name => "hash_url"
  add_index "boost_cache_relationships", ["page_callback"], :name => "page_callback"
  add_index "boost_cache_relationships", ["page_id"], :name => "page_id"
  add_index "boost_cache_relationships", ["page_type"], :name => "page_type"
  add_index "boost_cache_relationships", ["timestamp"], :name => "timestamp"

  create_table "boost_cache_settings", :primary_key => "csid", :force => true do |t|
    t.string  "base_dir",      :limit => 128, :default => "",  :null => false
    t.string  "page_callback",                :default => "",  :null => false
    t.string  "page_type",                    :default => "0", :null => false
    t.string  "page_id",       :limit => 64,  :default => "",  :null => false
    t.string  "extension",     :limit => 8,   :default => "",  :null => false
    t.integer "lifetime",                     :default => -1,  :null => false
    t.integer "push",          :limit => 2,   :default => -1,  :null => false
  end

  add_index "boost_cache_settings", ["base_dir"], :name => "base_dir"
  add_index "boost_cache_settings", ["extension"], :name => "extension"
  add_index "boost_cache_settings", ["page_callback"], :name => "page_callback"
  add_index "boost_cache_settings", ["page_id"], :name => "page_id"
  add_index "boost_cache_settings", ["page_type"], :name => "page_type"

  create_table "boost_crawler", :force => true do |t|
    t.string "hash", :limit => 32, :default => "", :null => false
    t.text   "url",                                :null => false
  end

  add_index "boost_crawler", ["hash"], :name => "hash", :unique => true

  create_table "boxes", :primary_key => "bid", :force => true do |t|
    t.text    "body",   :limit => 2147483647
    t.string  "info",   :limit => 128,        :default => "", :null => false
    t.integer "format", :limit => 2,          :default => 0,  :null => false
  end

  add_index "boxes", ["info"], :name => "info", :unique => true

  create_table "cache", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache", ["expire"], :name => "expire"

  create_table "cache_block", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_block", ["expire"], :name => "expire"

  create_table "cache_content", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_content", ["expire"], :name => "expire"

  create_table "cache_filter", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_filter", ["expire"], :name => "expire"

  create_table "cache_form", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_form", ["expire"], :name => "expire"

  create_table "cache_gravatar", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_gravatar", ["expire"], :name => "expire"

  create_table "cache_menu", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_menu", ["expire"], :name => "expire"

  create_table "cache_mollom", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_mollom", ["expire"], :name => "expire"

  create_table "cache_page", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_page", ["expire"], :name => "expire"

  create_table "cache_rules", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_rules", ["expire"], :name => "expire"

  create_table "cache_update", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_update", ["expire"], :name => "expire"

  create_table "cache_views", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 0, :null => false
  end

  add_index "cache_views", ["expire"], :name => "expire"

  create_table "cache_views_data", :primary_key => "cid", :force => true do |t|
    t.binary  "data",       :limit => 2147483647
    t.integer "expire",                           :default => 0, :null => false
    t.integer "created",                          :default => 0, :null => false
    t.text    "headers"
    t.integer "serialized", :limit => 2,          :default => 1, :null => false
  end

  add_index "cache_views_data", ["expire"], :name => "expire"

  create_table "captcha_points", :primary_key => "form_id", :force => true do |t|
    t.string "module",       :limit => 64
    t.string "captcha_type", :limit => 64
  end

  create_table "captcha_sessions", :primary_key => "csid", :force => true do |t|
    t.string  "token",      :limit => 64
    t.integer "uid",                       :default => 0,  :null => false
    t.string  "sid",        :limit => 64,  :default => "", :null => false
    t.string  "ip_address", :limit => 128
    t.integer "timestamp",                 :default => 0,  :null => false
    t.string  "form_id",    :limit => 128,                 :null => false
    t.string  "solution",   :limit => 128, :default => "", :null => false
    t.integer "status",                    :default => 0,  :null => false
    t.integer "attempts",                  :default => 0,  :null => false
  end

  add_index "captcha_sessions", ["csid", "ip_address"], :name => "csid_ip"

  create_table "comment_notify", :primary_key => "cid", :force => true do |t|
    t.integer "notify",      :limit => 1,                  :null => false
    t.string  "notify_hash", :limit => 32, :default => "", :null => false
    t.integer "notified",    :limit => 1,  :default => 0,  :null => false
  end

  add_index "comment_notify", ["notify_hash"], :name => "notify_hash"

  create_table "comment_notify_user_settings", :primary_key => "uid", :force => true do |t|
    t.integer "node_notify",    :limit => 1, :default => 0, :null => false
    t.integer "comment_notify", :limit => 1, :default => 0, :null => false
  end

  create_table "comments", :primary_key => "cid", :force => true do |t|
    t.integer "pid",                             :default => 0,  :null => false
    t.integer "nid",                             :default => 0,  :null => false
    t.integer "uid",                             :default => 0,  :null => false
    t.string  "subject",   :limit => 64,         :default => "", :null => false
    t.text    "comment",   :limit => 2147483647,                 :null => false
    t.string  "hostname",  :limit => 128,        :default => "", :null => false
    t.integer "timestamp",                       :default => 0,  :null => false
    t.integer "status",    :limit => 1,          :default => 0,  :null => false
    t.integer "format",    :limit => 2,          :default => 0,  :null => false
    t.string  "thread",                                          :null => false
    t.string  "name",      :limit => 60
    t.string  "mail",      :limit => 64
    t.string  "homepage"
    t.integer "flag",                            :default => 0,  :null => false
  end

  add_index "comments", ["nid"], :name => "nid"
  add_index "comments", ["pid"], :name => "pid"
  add_index "comments", ["status"], :name => "status"

  create_table "community_tags", :id => false, :force => true do |t|
    t.integer "tid",  :default => 0, :null => false
    t.integer "nid",  :default => 0, :null => false
    t.integer "uid",  :default => 0, :null => false
    t.integer "date", :default => 0, :null => false
  end

  add_index "community_tags", ["nid"], :name => "nid"
  add_index "community_tags", ["tid", "nid"], :name => "tid_nid"
  add_index "community_tags", ["tid"], :name => "tid"
  add_index "community_tags", ["uid"], :name => "uid"

  create_table "contact", :primary_key => "cid", :force => true do |t|
    t.string  "category",                         :default => "", :null => false
    t.text    "recipients", :limit => 2147483647,                 :null => false
    t.text    "reply",      :limit => 2147483647,                 :null => false
    t.integer "weight",     :limit => 1,          :default => 0,  :null => false
    t.integer "selected",   :limit => 1,          :default => 0,  :null => false
  end

  add_index "contact", ["category"], :name => "category", :unique => true
  add_index "contact", ["weight", "category"], :name => "list"

# Could not dump table "content_field_bbox" because of following StandardError
#   Unknown type 'geometry' for column 'field_bbox_geo'

  create_table "content_field_image_gallery", :id => false, :force => true do |t|
    t.integer "vid",                                   :default => 0, :null => false
    t.integer "nid",                                   :default => 0, :null => false
    t.integer "delta",                                 :default => 0, :null => false
    t.integer "field_image_gallery_fid"
    t.integer "field_image_gallery_list", :limit => 1
    t.text    "field_image_gallery_data"
  end

  add_index "content_field_image_gallery", ["nid"], :name => "nid"

  create_table "content_field_main_image", :primary_key => "vid", :force => true do |t|
    t.integer "nid",                                :default => 0, :null => false
    t.integer "field_main_image_fid"
    t.integer "field_main_image_list", :limit => 1
    t.text    "field_main_image_data"
  end

  add_index "content_field_main_image", ["nid"], :name => "nid"

  create_table "content_field_map", :id => false, :force => true do |t|
    t.integer "vid",                                            :default => 0, :null => false
    t.integer "nid",                                            :default => 0, :null => false
    t.text    "field_map_openlayers_wkt", :limit => 2147483647
    t.integer "delta",                                          :default => 0, :null => false
  end

  add_index "content_field_map", ["nid"], :name => "nid"

  create_table "content_field_map_editor", :id => false, :force => true do |t|
    t.integer "vid",                                          :default => 0, :null => false
    t.integer "nid",                                          :default => 0, :null => false
    t.integer "delta",                                        :default => 0, :null => false
    t.text    "field_map_editor_value", :limit => 2147483647
  end

  add_index "content_field_map_editor", ["nid"], :name => "nid"

  create_table "content_field_mappers", :id => false, :force => true do |t|
    t.integer "vid",                                       :default => 0, :null => false
    t.integer "nid",                                       :default => 0, :null => false
    t.integer "delta",                                     :default => 0, :null => false
    t.text    "field_mappers_value", :limit => 2147483647
  end

  add_index "content_field_mappers", ["nid"], :name => "nid"

  create_table "content_group", :id => false, :force => true do |t|
    t.string  "group_type", :limit => 32,       :default => "standard", :null => false
    t.string  "type_name",  :limit => 32,       :default => "",         :null => false
    t.string  "group_name", :limit => 32,       :default => "",         :null => false
    t.string  "label",                          :default => "",         :null => false
    t.text    "settings",   :limit => 16777215,                         :null => false
    t.integer "weight",                         :default => 0,          :null => false
  end

  create_table "content_group_fields", :id => false, :force => true do |t|
    t.string "type_name",  :limit => 32, :default => "", :null => false
    t.string "group_name", :limit => 32, :default => "", :null => false
    t.string "field_name", :limit => 32, :default => "", :null => false
  end

  create_table "content_node_field", :primary_key => "field_name", :force => true do |t|
    t.string  "type",            :limit => 127,      :default => "", :null => false
    t.text    "global_settings", :limit => 16777215,                 :null => false
    t.integer "required",        :limit => 1,        :default => 0,  :null => false
    t.integer "multiple",        :limit => 1,        :default => 0,  :null => false
    t.integer "db_storage",      :limit => 1,        :default => 1,  :null => false
    t.string  "module",          :limit => 127,      :default => "", :null => false
    t.text    "db_columns",      :limit => 16777215,                 :null => false
    t.integer "active",          :limit => 1,        :default => 0,  :null => false
    t.integer "locked",          :limit => 1,        :default => 0,  :null => false
  end

  create_table "content_node_field_instance", :id => false, :force => true do |t|
    t.string  "field_name",       :limit => 32,       :default => "", :null => false
    t.string  "type_name",        :limit => 32,       :default => "", :null => false
    t.integer "weight",                               :default => 0,  :null => false
    t.string  "label",                                :default => "", :null => false
    t.string  "widget_type",      :limit => 32,       :default => "", :null => false
    t.text    "widget_settings",  :limit => 16777215,                 :null => false
    t.text    "display_settings", :limit => 16777215,                 :null => false
    t.text    "description",      :limit => 16777215,                 :null => false
    t.string  "widget_module",    :limit => 127,      :default => "", :null => false
    t.integer "widget_active",    :limit => 1,        :default => 0,  :null => false
  end

  create_table "content_type_blog", :primary_key => "vid", :force => true do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_blog", ["nid"], :name => "nid"

  create_table "content_type_map", :primary_key => "vid", :force => true do |t|
    t.integer "nid",                                                                                  :default => 0, :null => false
    t.string  "field_publication_date_value",    :limit => 20
    t.string  "field_capture_date_value",        :limit => 20
    t.text    "field_geotiff_url_value",         :limit => 2147483647
    t.text    "field_google_maps_url_value",     :limit => 2147483647
    t.text    "field_openlayers_url_value",      :limit => 2147483647
    t.text    "field_tms_url_value",             :limit => 2147483647
    t.text    "field_jpg_url_value",             :limit => 2147483647
    t.text    "field_license_value",             :limit => 2147483647
    t.text    "field_raw_images_value",          :limit => 2147483647
    t.text    "field_cartographer_notes_value",  :limit => 2147483647
    t.integer "field_cartographer_notes_format"
    t.text    "field_notes_value",               :limit => 2147483647
    t.integer "field_notes_format"
    t.text    "field_mbtiles_url_value",         :limit => 2147483647
    t.integer "field_zoom_min_value"
    t.decimal "field_ground_resolution_value",                         :precision => 10, :scale => 2
    t.decimal "field_geotiff_filesize_value",                          :precision => 10, :scale => 1
    t.decimal "field_jpg_filesize_value",                              :precision => 10, :scale => 1
    t.decimal "field_raw_images_filesize_value",                       :precision => 10, :scale => 1
    t.text    "field_tms_tile_type_value",       :limit => 2147483647
    t.integer "field_zoom_max_value"
  end

  add_index "content_type_map", ["nid"], :name => "nid"

  create_table "content_type_note", :primary_key => "vid", :force => true do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_note", ["nid"], :name => "nid"

  create_table "content_type_page", :primary_key => "vid", :force => true do |t|
    t.integer "nid",             :default => 0, :null => false
    t.integer "field_toc_value"
  end

  add_index "content_type_page", ["nid"], :name => "nid"

  create_table "content_type_place", :primary_key => "vid", :force => true do |t|
    t.integer "nid",                                          :default => 0, :null => false
    t.integer "field_host_logo_fid"
    t.integer "field_host_logo_list",   :limit => 1
    t.text    "field_host_logo_data"
    t.text    "field_host_name_value",  :limit => 2147483647
    t.integer "field_host_name_format"
  end

  add_index "content_type_place", ["nid"], :name => "nid"

  create_table "content_type_report", :primary_key => "vid", :force => true do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_report", ["nid"], :name => "nid"

  create_table "content_type_tool", :primary_key => "vid", :force => true do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_tool", ["nid"], :name => "nid"

  create_table "context", :primary_key => "name", :force => true do |t|
    t.string  "description",    :default => "", :null => false
    t.string  "tag",            :default => "", :null => false
    t.text    "conditions"
    t.text    "reactions"
    t.integer "condition_mode", :default => 0
  end

  create_table "ctools_access_ruleset", :primary_key => "rsid", :force => true do |t|
    t.string "name"
    t.string "admin_title"
    t.text   "admin_description", :limit => 2147483647
    t.text   "requiredcontexts",  :limit => 2147483647
    t.text   "contexts",          :limit => 2147483647
    t.text   "relationships",     :limit => 2147483647
    t.text   "access",            :limit => 2147483647
  end

  create_table "ctools_css_cache", :primary_key => "cid", :force => true do |t|
    t.string  "filename"
    t.text    "css",      :limit => 2147483647
    t.integer "filter",   :limit => 1
  end

  create_table "ctools_custom_content", :primary_key => "cid", :force => true do |t|
    t.string "name"
    t.string "admin_title"
    t.text   "admin_description", :limit => 2147483647
    t.string "category"
    t.text   "settings",          :limit => 2147483647
  end

  create_table "ctools_object_cache", :id => false, :force => true do |t|
    t.string  "sid",     :limit => 64,                        :null => false
    t.string  "name",    :limit => 128,                       :null => false
    t.string  "obj",     :limit => 32,                        :null => false
    t.integer "updated",                       :default => 0, :null => false
    t.text    "data",    :limit => 2147483647
  end

  add_index "ctools_object_cache", ["updated"], :name => "updated"

  create_table "custom_breadcrumb", :primary_key => "bid", :force => true do |t|
    t.string "titles",                             :default => "",    :null => false
    t.string "paths"
    t.text   "visibility_php", :limit => 16777215,                    :null => false
    t.string "node_type",      :limit => 64,       :default => "AND"
  end

  create_table "dashboard_default", :force => true do |t|
    t.string  "title",                                 :null => false
    t.string  "description",                           :null => false
    t.integer "thumbnail"
    t.string  "tags",                                  :null => false
    t.integer "default_enabled", :limit => 1,          :null => false
    t.string  "widget_type",     :limit => 32,         :null => false
    t.string  "subtype",         :limit => 64,         :null => false
    t.binary  "conf",            :limit => 2147483647, :null => false
  end

  create_table "dashboard_page", :primary_key => "page_id", :force => true do |t|
    t.integer "uid",                  :null => false
    t.string  "path",   :limit => 22, :null => false
    t.integer "weight", :limit => 1,  :null => false
    t.string  "title",  :limit => 20, :null => false
  end

  add_index "dashboard_page", ["uid", "path"], :name => "uid_path", :unique => true
  add_index "dashboard_page", ["uid", "weight"], :name => "uid_weight"

  create_table "dashboard_widget", :id => false, :force => true do |t|
    t.integer "widget_id",                                       :null => false
    t.integer "page_id",                                         :null => false
    t.string  "type",      :limit => 32,         :default => ""
    t.string  "subtype",   :limit => 64,         :default => ""
    t.binary  "conf",      :limit => 2147483647
    t.integer "col",       :limit => 1,                          :null => false
    t.integer "weight",    :limit => 1,                          :null => false
  end

  add_index "dashboard_widget", ["page_id", "weight"], :name => "page_id_weight"

  create_table "date_format_locale", :id => false, :force => true do |t|
    t.string "format",   :limit => 100, :null => false
    t.string "type",     :limit => 200, :null => false
    t.string "language", :limit => 12,  :null => false
  end

  create_table "date_format_types", :primary_key => "type", :force => true do |t|
    t.string  "title",                              :null => false
    t.integer "locked", :limit => 1, :default => 0, :null => false
  end

  create_table "date_formats", :primary_key => "dfid", :force => true do |t|
    t.string  "format", :limit => 100,                :null => false
    t.string  "type",   :limit => 200,                :null => false
    t.integer "locked", :limit => 1,   :default => 0, :null => false
  end

  add_index "date_formats", ["format", "type"], :name => "formats", :unique => true

  create_table "devel_queries", :primary_key => "hash", :force => true do |t|
    t.integer "qid",                      :null => false
    t.string  "function", :default => "", :null => false
    t.text    "query",                    :null => false
  end

  add_index "devel_queries", ["qid"], :name => "qid"

  create_table "devel_times", :primary_key => "tid", :force => true do |t|
    t.integer "qid",  :default => 0, :null => false
    t.float   "time"
  end

  add_index "devel_times", ["qid"], :name => "qid"

  create_table "event", :primary_key => "nid", :force => true do |t|
    t.datetime "event_start",                 :null => false
    t.datetime "event_end",                   :null => false
    t.integer  "timezone",     :default => 0, :null => false
    t.integer  "start_in_dst", :default => 0, :null => false
    t.integer  "end_in_dst",   :default => 0, :null => false
    t.integer  "has_time",     :default => 1, :null => false
    t.integer  "has_end_date", :default => 1, :null => false
  end

  add_index "event", ["event_end"], :name => "event_end"
  add_index "event", ["event_start"], :name => "event_start"
  add_index "event", ["timezone"], :name => "timezone"

  create_table "event_timezones", :primary_key => "timezone", :force => true do |t|
    t.string  "name",       :default => "",                    :null => false
    t.time    "offset",     :default => '2000-01-01 00:00:00', :null => false
    t.time    "offset_dst", :default => '2000-01-01 00:00:00', :null => false
    t.integer "dst_region", :default => 0,                     :null => false
    t.integer "is_dst",     :default => 0,                     :null => false
  end

  create_table "feeds_imagegrabber", :primary_key => "feed_nid", :force => true do |t|
    t.integer "enabled",                      :default => 0,  :null => false
    t.integer "id_class",                     :default => 0,  :null => false
    t.string  "id_class_desc", :limit => 128
    t.integer "feeling_lucky",                :default => 0,  :null => false
    t.integer "exec_time",                    :default => 10, :null => false
  end

  create_table "feeds_importer", :force => true do |t|
    t.text "config"
  end

  create_table "feeds_node_item", :primary_key => "nid", :force => true do |t|
    t.string  "id",       :limit => 128, :default => "", :null => false
    t.integer "feed_nid",                                :null => false
    t.integer "imported",                :default => 0,  :null => false
    t.text    "url",                                     :null => false
    t.text    "guid",                                    :null => false
    t.string  "hash",     :limit => 32,  :default => "", :null => false
  end

  add_index "feeds_node_item", ["feed_nid"], :name => "feed_nid"
  add_index "feeds_node_item", ["guid"], :name => "guid", :length => {"guid"=>"255"}
  add_index "feeds_node_item", ["id"], :name => "id"
  add_index "feeds_node_item", ["imported"], :name => "imported"
  add_index "feeds_node_item", ["url"], :name => "url", :length => {"url"=>"255"}

  create_table "feeds_push_subscriptions", :id => false, :force => true do |t|
    t.string  "domain",        :limit => 128, :default => "", :null => false
    t.integer "subscriber_id",                :default => 0,  :null => false
    t.integer "timestamp",                    :default => 0,  :null => false
    t.text    "hub",                                          :null => false
    t.text    "topic",                                        :null => false
    t.string  "secret",        :limit => 128, :default => "", :null => false
    t.string  "status",        :limit => 64,  :default => "", :null => false
    t.text    "post_fields"
  end

  add_index "feeds_push_subscriptions", ["timestamp"], :name => "timestamp"

  create_table "feeds_source", :id => false, :force => true do |t|
    t.string  "id",       :limit => 128,        :default => "", :null => false
    t.integer "feed_nid",                       :default => 0,  :null => false
    t.text    "config"
    t.text    "source",                                         :null => false
    t.text    "batch",    :limit => 2147483647
  end

  add_index "feeds_source", ["feed_nid"], :name => "feed_nid"
  add_index "feeds_source", ["id", "source"], :name => "id_source", :length => {"id"=>nil, "source"=>"128"}
  add_index "feeds_source", ["id"], :name => "id"

  create_table "feeds_term_item", :primary_key => "tid", :force => true do |t|
    t.string  "id",       :limit => 128, :default => "", :null => false
    t.integer "feed_nid",                                :null => false
  end

  add_index "feeds_term_item", ["feed_nid"], :name => "feed_nid"
  add_index "feeds_term_item", ["id", "feed_nid"], :name => "id_feed_nid"

  create_table "files", :primary_key => "fid", :force => true do |t|
    t.integer "uid",       :default => 0,  :null => false
    t.string  "filename",  :default => "", :null => false
    t.string  "filepath",  :default => "", :null => false
    t.string  "filemime",  :default => "", :null => false
    t.integer "filesize",  :default => 0,  :null => false
    t.integer "status",    :default => 0,  :null => false
    t.integer "timestamp", :default => 0,  :null => false
  end

  add_index "files", ["status"], :name => "status"
  add_index "files", ["timestamp"], :name => "timestamp"
  add_index "files", ["uid"], :name => "uid"

  create_table "filter_formats", :primary_key => "format", :force => true do |t|
    t.string  "name",               :default => "", :null => false
    t.string  "roles",              :default => "", :null => false
    t.integer "cache", :limit => 1, :default => 0,  :null => false
  end

  add_index "filter_formats", ["name"], :name => "name", :unique => true

  create_table "filters", :primary_key => "fid", :force => true do |t|
    t.integer "format",               :default => 0,  :null => false
    t.string  "module", :limit => 64, :default => "", :null => false
    t.integer "delta",  :limit => 1,  :default => 0,  :null => false
    t.integer "weight", :limit => 1,  :default => 0,  :null => false
  end

  add_index "filters", ["format", "module", "delta"], :name => "fmd", :unique => true
  add_index "filters", ["format", "weight", "module", "delta"], :name => "list"

  create_table "flood", :primary_key => "fid", :force => true do |t|
    t.string  "event",     :limit => 64,  :default => "", :null => false
    t.string  "hostname",  :limit => 128, :default => "", :null => false
    t.integer "timestamp",                :default => 0,  :null => false
  end

  add_index "flood", ["event", "hostname", "timestamp"], :name => "allow"

  create_table "freelinking", :primary_key => "hash", :force => true do |t|
    t.string "phrase", :limit => 200, :null => false
    t.string "path",   :limit => 200, :null => false
    t.string "args",   :limit => 200, :null => false
  end

  create_table "geo", :primary_key => "gid", :force => true do |t|
    t.string  "name",                                      :null => false
    t.string  "title",                                     :null => false
    t.string  "handler",     :limit => 32,                 :null => false
    t.string  "table_name"
    t.string  "column_name"
    t.integer "geo_type",                                  :null => false
    t.integer "srid",                      :default => -1, :null => false
    t.integer "indexed",     :limit => 1,  :default => 0
    t.text    "data"
  end

  create_table "history", :id => false, :force => true do |t|
    t.integer "uid",       :default => 0, :null => false
    t.integer "nid",       :default => 0, :null => false
    t.integer "timestamp", :default => 0, :null => false
  end

  add_index "history", ["nid"], :name => "nid"

  create_table "imagecache_action", :primary_key => "actionid", :force => true do |t|
    t.integer "presetid",                       :default => 0, :null => false
    t.integer "weight",                         :default => 0, :null => false
    t.string  "module",                                        :null => false
    t.string  "action",                                        :null => false
    t.text    "data",     :limit => 2147483647,                :null => false
  end

  add_index "imagecache_action", ["presetid"], :name => "presetid"

  create_table "imagecache_preset", :primary_key => "presetid", :force => true do |t|
    t.string "presetname", :null => false
  end

  create_table "invite", :primary_key => "iid", :force => true do |t|
    t.string  "reg_code", :limit => 8,   :default => "", :null => false
    t.string  "email",    :limit => 100, :default => "", :null => false
    t.integer "uid",                     :default => 0,  :null => false
    t.integer "invitee",                 :default => 0,  :null => false
    t.integer "created",                 :default => 0,  :null => false
    t.integer "expiry",                  :default => 0,  :null => false
    t.integer "joined",                  :default => 0,  :null => false
    t.integer "canceled", :limit => 1,   :default => 0,  :null => false
    t.integer "resent",   :limit => 1,   :default => 0,  :null => false
    t.text    "data",                                    :null => false
  end

  add_index "invite", ["email"], :name => "email"
  add_index "invite", ["reg_code"], :name => "reg_code", :unique => true
  add_index "invite", ["uid"], :name => "uid"

  create_table "invite_notifications", :id => false, :force => true do |t|
    t.integer "uid",     :default => 0, :null => false
    t.integer "invitee", :default => 0, :null => false
  end

  add_index "invite_notifications", ["uid", "invitee"], :name => "uid_invitee", :unique => true

  create_table "job_schedule", :id => false, :force => true do |t|
    t.string  "callback",  :limit => 128, :default => "", :null => false
    t.string  "type",      :limit => 128, :default => "", :null => false
    t.integer "id",                       :default => 0,  :null => false
    t.integer "last",                     :default => 0,  :null => false
    t.integer "period",                   :default => 0,  :null => false
    t.integer "next",                     :default => 0,  :null => false
    t.integer "periodic",  :limit => 2,   :default => 0,  :null => false
    t.integer "scheduled",                :default => 0,  :null => false
  end

  add_index "job_schedule", ["callback", "type", "id"], :name => "callback_type_id"
  add_index "job_schedule", ["callback", "type"], :name => "callback_type"
  add_index "job_schedule", ["next"], :name => "next"
  add_index "job_schedule", ["scheduled"], :name => "scheduled"

  create_table "languages", :primary_key => "language", :force => true do |t|
    t.string  "name",       :limit => 64,  :default => "", :null => false
    t.string  "native",     :limit => 64,  :default => "", :null => false
    t.integer "direction",                 :default => 0,  :null => false
    t.integer "enabled",                   :default => 0,  :null => false
    t.integer "plurals",                   :default => 0,  :null => false
    t.string  "formula",    :limit => 128, :default => "", :null => false
    t.string  "domain",     :limit => 128, :default => "", :null => false
    t.string  "prefix",     :limit => 128, :default => "", :null => false
    t.integer "weight",                    :default => 0,  :null => false
    t.string  "javascript", :limit => 32,  :default => "", :null => false
  end

  add_index "languages", ["weight", "name"], :name => "list"

  create_table "locales_source", :primary_key => "lid", :force => true do |t|
    t.string "location",                :default => "",        :null => false
    t.string "textgroup",               :default => "default", :null => false
    t.binary "source",                                         :null => false
    t.string "version",   :limit => 20, :default => "none",    :null => false
  end

  add_index "locales_source", ["source"], :name => "source", :length => {"source"=>"30"}

  create_table "locales_target", :id => false, :force => true do |t|
    t.integer "lid",                       :default => 0,  :null => false
    t.binary  "translation",                               :null => false
    t.string  "language",    :limit => 12, :default => "", :null => false
    t.integer "plid",                      :default => 0,  :null => false
    t.integer "plural",                    :default => 0,  :null => false
  end

  add_index "locales_target", ["lid"], :name => "lid"
  add_index "locales_target", ["plid"], :name => "plid"
  add_index "locales_target", ["plural"], :name => "plural"

  create_table "mailhandler", :primary_key => "mid", :force => true do |t|
    t.string  "mail",                                                                :null => false
    t.string  "domain",                                                              :null => false
    t.integer "port",                                                                :null => false
    t.string  "name",                                                                :null => false
    t.string  "pass",                                                                :null => false
    t.integer "security",          :limit => 1,                                      :null => false
    t.integer "replies",           :limit => 1,   :default => 1,                     :null => false
    t.string  "fromheader",        :limit => 128
    t.text    "commands"
    t.string  "sigseparator",      :limit => 128
    t.integer "enabled",           :limit => 1
    t.string  "folder",                                                              :null => false
    t.integer "imap",              :limit => 1,                                      :null => false
    t.string  "mime",              :limit => 128
    t.string  "mailto",                                                              :null => false
    t.integer "delete_after_read", :limit => 1,   :default => 1,                     :null => false
    t.string  "extraimap",                                                           :null => false
    t.integer "format",                           :default => 0,                     :null => false
    t.string  "authentication",                   :default => "mailhandler_default", :null => false
  end

  add_index "mailhandler", ["mail"], :name => "mail"

  create_table "menu_custom", :primary_key => "menu_name", :force => true do |t|
    t.string "title",       :default => "", :null => false
    t.text   "description"
  end

  create_table "menu_links", :primary_key => "mlid", :force => true do |t|
    t.string  "menu_name",    :limit => 32, :default => "",       :null => false
    t.integer "plid",                       :default => 0,        :null => false
    t.string  "link_path",                  :default => "",       :null => false
    t.string  "router_path",                :default => "",       :null => false
    t.string  "link_title",                 :default => "",       :null => false
    t.text    "options"
    t.string  "module",                     :default => "system", :null => false
    t.integer "hidden",       :limit => 2,  :default => 0,        :null => false
    t.integer "external",     :limit => 2,  :default => 0,        :null => false
    t.integer "has_children", :limit => 2,  :default => 0,        :null => false
    t.integer "expanded",     :limit => 2,  :default => 0,        :null => false
    t.integer "weight",                     :default => 0,        :null => false
    t.integer "depth",        :limit => 2,  :default => 0,        :null => false
    t.integer "customized",   :limit => 2,  :default => 0,        :null => false
    t.integer "p1",                         :default => 0,        :null => false
    t.integer "p2",                         :default => 0,        :null => false
    t.integer "p3",                         :default => 0,        :null => false
    t.integer "p4",                         :default => 0,        :null => false
    t.integer "p5",                         :default => 0,        :null => false
    t.integer "p6",                         :default => 0,        :null => false
    t.integer "p7",                         :default => 0,        :null => false
    t.integer "p8",                         :default => 0,        :null => false
    t.integer "p9",                         :default => 0,        :null => false
    t.integer "updated",      :limit => 2,  :default => 0,        :null => false
  end

  add_index "menu_links", ["link_path", "menu_name"], :name => "path_menu", :length => {"link_path"=>"128", "menu_name"=>nil}
  add_index "menu_links", ["menu_name", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9"], :name => "menu_parents"
  add_index "menu_links", ["menu_name", "plid", "expanded", "has_children"], :name => "menu_plid_expand_child"
  add_index "menu_links", ["router_path"], :name => "router_path", :length => {"router_path"=>"128"}

  create_table "menu_router", :primary_key => "path", :force => true do |t|
    t.text    "load_functions",                                       :null => false
    t.text    "to_arg_functions",                                     :null => false
    t.string  "access_callback",                      :default => "", :null => false
    t.text    "access_arguments"
    t.string  "page_callback",                        :default => "", :null => false
    t.text    "page_arguments"
    t.integer "fit",                                  :default => 0,  :null => false
    t.integer "number_parts",     :limit => 2,        :default => 0,  :null => false
    t.string  "tab_parent",                           :default => "", :null => false
    t.string  "tab_root",                             :default => "", :null => false
    t.string  "title",                                :default => "", :null => false
    t.string  "title_callback",                       :default => "", :null => false
    t.string  "title_arguments",                      :default => "", :null => false
    t.integer "type",                                 :default => 0,  :null => false
    t.string  "block_callback",                       :default => "", :null => false
    t.text    "description",                                          :null => false
    t.string  "position",                             :default => "", :null => false
    t.integer "weight",                               :default => 0,  :null => false
    t.text    "file",             :limit => 16777215
  end

  add_index "menu_router", ["fit"], :name => "fit"
  add_index "menu_router", ["tab_parent"], :name => "tab_parent"
  add_index "menu_router", ["tab_root", "weight", "title"], :name => "tab_root_weight_title", :length => {"tab_root"=>"64", "weight"=>nil, "title"=>nil}

  create_table "messaging_message_parts", :id => false, :force => true do |t|
    t.string "type",    :limit => 100,        :default => "", :null => false
    t.string "method",  :limit => 50,         :default => "", :null => false
    t.string "msgkey",  :limit => 100,        :default => "", :null => false
    t.string "module",                        :default => "", :null => false
    t.text   "message", :limit => 2147483647,                 :null => false
  end

  add_index "messaging_message_parts", ["method"], :name => "method"
  add_index "messaging_message_parts", ["msgkey"], :name => "msgkey"
  add_index "messaging_message_parts", ["type"], :name => "type"

  create_table "messaging_store", :primary_key => "mqid", :force => true do |t|
    t.integer "uid",                               :default => 0,  :null => false
    t.integer "sender",                            :default => 0,  :null => false
    t.string  "method",                            :default => "", :null => false
    t.string  "destination",                       :default => "", :null => false
    t.string  "subject",                           :default => "", :null => false
    t.text    "body",        :limit => 2147483647,                 :null => false
    t.text    "params",      :limit => 2147483647,                 :null => false
    t.integer "created",                           :default => 0,  :null => false
    t.integer "sent",                              :default => 0,  :null => false
    t.integer "cron",        :limit => 1,          :default => 0,  :null => false
    t.integer "queue",       :limit => 1,          :default => 0,  :null => false
    t.integer "log",         :limit => 1,          :default => 0,  :null => false
  end

  add_index "messaging_store", ["cron"], :name => "cron"
  add_index "messaging_store", ["log"], :name => "log"
  add_index "messaging_store", ["queue"], :name => "queue"

  create_table "mollom", :id => false, :force => true do |t|
    t.string  "entity",     :limit => 32, :default => "", :null => false
    t.string  "id",         :limit => 32, :default => "", :null => false
    t.string  "session_id",               :default => "", :null => false
    t.string  "form_id",                  :default => "", :null => false
    t.integer "changed",                  :default => 0,  :null => false
    t.integer "spam",       :limit => 1
    t.float   "quality"
    t.float   "profanity"
    t.string  "languages",                :default => "", :null => false
  end

  add_index "mollom", ["session_id"], :name => "session_id"

  create_table "mollom_form", :primary_key => "form_id", :force => true do |t|
    t.integer "mode",           :limit => 1, :default => 0,        :null => false
    t.text    "checks"
    t.integer "discard",        :limit => 1, :default => 1,        :null => false
    t.text    "enabled_fields"
    t.string  "strictness",     :limit => 8, :default => "normal", :null => false
    t.string  "module",                      :default => "",       :null => false
  end

  create_table "node", :primary_key => "nid", :force => true do |t|
    t.integer "vid",                     :default => 0,  :null => false
    t.string  "type",      :limit => 32, :default => "", :null => false
    t.string  "language",  :limit => 12, :default => "", :null => false
    t.string  "title",                   :default => "", :null => false
    t.integer "uid",                     :default => 0,  :null => false
    t.integer "status",                  :default => 1,  :null => false
    t.integer "created",                 :default => 0,  :null => false
    t.integer "changed",                 :default => 0,  :null => false
    t.integer "comment",                 :default => 0,  :null => false
    t.integer "promote",                 :default => 0,  :null => false
    t.integer "moderate",                :default => 0,  :null => false
    t.integer "sticky",                  :default => 0,  :null => false
    t.integer "tnid",                    :default => 0,  :null => false
    t.integer "translate",               :default => 0,  :null => false
    t.integer "flag",                    :default => 0,  :null => false
  end

  add_index "node", ["changed"], :name => "node_changed"
  add_index "node", ["created"], :name => "node_created"
  add_index "node", ["moderate"], :name => "node_moderate"
  add_index "node", ["promote", "status"], :name => "node_promote_status"
  add_index "node", ["status", "type", "nid"], :name => "node_status_type"
  add_index "node", ["title", "type"], :name => "node_title_type", :length => {"title"=>nil, "type"=>"4"}
  add_index "node", ["tnid"], :name => "tnid"
  add_index "node", ["translate"], :name => "translate"
  add_index "node", ["type"], :name => "node_type", :length => {"type"=>"4"}
  add_index "node", ["uid"], :name => "uid"
  add_index "node", ["vid"], :name => "vid", :unique => true

  create_table "node_access", :id => false, :force => true do |t|
    t.integer "nid",                       :default => 0,  :null => false
    t.integer "gid",                       :default => 0,  :null => false
    t.string  "realm",                     :default => "", :null => false
    t.integer "grant_view",   :limit => 1, :default => 0,  :null => false
    t.integer "grant_update", :limit => 1, :default => 0,  :null => false
    t.integer "grant_delete", :limit => 1, :default => 0,  :null => false
  end

  create_table "node_comment_statistics", :primary_key => "nid", :force => true do |t|
    t.integer "last_comment_timestamp",               :default => 0, :null => false
    t.string  "last_comment_name",      :limit => 60
    t.integer "last_comment_uid",                     :default => 0, :null => false
    t.integer "comment_count",                        :default => 0, :null => false
  end

  add_index "node_comment_statistics", ["last_comment_timestamp"], :name => "node_comment_timestamp"

  create_table "node_counter", :primary_key => "nid", :force => true do |t|
    t.integer "totalcount", :limit => 8, :default => 0, :null => false
    t.integer "daycount",   :limit => 3, :default => 0, :null => false
    t.integer "timestamp",               :default => 0, :null => false
  end

  create_table "node_images", :force => true do |t|
    t.integer "nid",                      :default => 0,  :null => false
    t.integer "uid",                      :default => 0,  :null => false
    t.string  "filename",                 :default => "", :null => false
    t.string  "filepath",                 :default => "", :null => false
    t.string  "filemime",                 :default => "", :null => false
    t.integer "filesize",                 :default => 0,  :null => false
    t.string  "thumbpath",                :default => "", :null => false
    t.integer "thumbsize",                :default => 0,  :null => false
    t.integer "status",      :limit => 2, :default => 1,  :null => false
    t.integer "weight",      :limit => 2, :default => 0,  :null => false
    t.string  "description",              :default => "", :null => false
    t.integer "timestamp",                :default => 0
    t.integer "list",        :limit => 1, :default => 1,  :null => false
  end

  add_index "node_images", ["nid", "status"], :name => "nid_status"
  add_index "node_images", ["uid"], :name => "uid"

  create_table "node_revisions", :primary_key => "vid", :force => true do |t|
    t.integer "nid",                             :default => 0,  :null => false
    t.integer "uid",                             :default => 0,  :null => false
    t.string  "title",                           :default => "", :null => false
    t.text    "body",      :limit => 2147483647,                 :null => false
    t.text    "teaser",    :limit => 2147483647,                 :null => false
    t.text    "log",       :limit => 2147483647,                 :null => false
    t.integer "timestamp",                       :default => 0,  :null => false
    t.integer "format",                          :default => 0,  :null => false
  end

  add_index "node_revisions", ["nid"], :name => "nid"
  add_index "node_revisions", ["uid"], :name => "uid"

  create_table "node_type", :primary_key => "type", :force => true do |t|
    t.string  "name",                               :default => "", :null => false
    t.string  "module",                                             :null => false
    t.text    "description",    :limit => 16777215,                 :null => false
    t.text    "help",           :limit => 16777215,                 :null => false
    t.integer "has_title",      :limit => 1,                        :null => false
    t.string  "title_label",                        :default => "", :null => false
    t.integer "has_body",       :limit => 1,                        :null => false
    t.string  "body_label",                         :default => "", :null => false
    t.integer "min_word_count", :limit => 2,                        :null => false
    t.integer "custom",         :limit => 1,        :default => 0,  :null => false
    t.integer "modified",       :limit => 1,        :default => 0,  :null => false
    t.integer "locked",         :limit => 1,        :default => 0,  :null => false
    t.string  "orig_type",                          :default => "", :null => false
  end

  create_table "notifications", :primary_key => "sid", :force => true do |t|
    t.integer "uid",                                       :null => false
    t.string  "type"
    t.string  "event_type"
    t.integer "conditions",                                :null => false
    t.integer "send_interval"
    t.string  "send_method",                               :null => false
    t.integer "cron",          :limit => 1, :default => 0, :null => false
    t.string  "module"
    t.integer "status",                     :default => 1, :null => false
    t.string  "destination"
  end

  create_table "notifications_event", :primary_key => "eid", :force => true do |t|
    t.string  "module"
    t.string  "type"
    t.string  "action"
    t.integer "oid",      :default => 0, :null => false
    t.string  "language"
    t.integer "uid"
    t.text    "params"
    t.integer "created",  :default => 0, :null => false
    t.integer "counter",  :default => 0, :null => false
  end

  create_table "notifications_fields", :id => false, :force => true do |t|
    t.integer "sid",                   :null => false
    t.string  "field",                 :null => false
    t.string  "value",                 :null => false
    t.integer "intval", :default => 0, :null => false
  end

  create_table "notifications_queue", :primary_key => "sqid", :force => true do |t|
    t.integer "eid",                        :default => 0, :null => false
    t.integer "sid",                        :default => 0, :null => false
    t.integer "uid"
    t.string  "language"
    t.string  "type"
    t.integer "send_interval"
    t.string  "send_method"
    t.integer "sent",                       :default => 0, :null => false
    t.integer "created",                    :default => 0, :null => false
    t.integer "cron",          :limit => 1, :default => 0, :null => false
    t.integer "conditions",                 :default => 0, :null => false
    t.string  "module"
    t.string  "destination"
  end

  create_table "notifications_sent", :id => false, :force => true do |t|
    t.integer "uid",                         :default => 0, :null => false
    t.integer "send_interval",               :default => 0, :null => false
    t.string  "send_method",   :limit => 50,                :null => false
    t.integer "sent",                        :default => 0, :null => false
  end

  create_table "notify", :primary_key => "uid", :force => true do |t|
    t.integer "status",   :limit => 1, :default => 0, :null => false
    t.integer "node",     :limit => 1, :default => 0, :null => false
    t.integer "comment",  :limit => 1, :default => 0, :null => false
    t.integer "attempts", :limit => 1, :default => 0, :null => false
    t.integer "teasers",  :limit => 1, :default => 0, :null => false
  end

  create_table "openid_association", :primary_key => "assoc_handle", :force => true do |t|
    t.string  "idp_endpoint_uri"
    t.string  "assoc_type",       :limit => 32
    t.string  "session_type",     :limit => 32
    t.string  "mac_key"
    t.integer "created",                        :default => 0, :null => false
    t.integer "expires_in",                     :default => 0, :null => false
  end

  create_table "openid_nonce", :id => false, :force => true do |t|
    t.string  "idp_endpoint_uri"
    t.string  "nonce"
    t.integer "expires",          :default => 0, :null => false
  end

  add_index "openid_nonce", ["expires"], :name => "expires"
  add_index "openid_nonce", ["nonce"], :name => "nonce"

  create_table "openid_provider_association", :primary_key => "assoc_handle", :force => true do |t|
    t.string  "assoc_type",   :limit => 32, :default => "", :null => false
    t.string  "session_type", :limit => 32, :default => "", :null => false
    t.string  "mac_key",                    :default => "", :null => false
    t.integer "created",                    :default => 0,  :null => false
    t.integer "expires_in",                 :default => 0,  :null => false
  end

  create_table "openid_provider_relying_party", :primary_key => "rpid", :force => true do |t|
    t.integer "uid",                          :null => false
    t.string  "realm",        :default => "", :null => false
    t.integer "first_time",   :default => 0,  :null => false
    t.integer "last_time",    :default => 0,  :null => false
    t.integer "auto_release", :default => 0,  :null => false
  end

  add_index "openid_provider_relying_party", ["uid"], :name => "uid"

  create_table "openlayers_layers", :primary_key => "name", :force => true do |t|
    t.string "title",       :default => "", :null => false
    t.text   "description",                 :null => false
    t.text   "data"
  end

  add_index "openlayers_layers", ["name"], :name => "name"

  create_table "openlayers_map_presets", :primary_key => "name", :force => true do |t|
    t.string "title",       :null => false
    t.text   "description", :null => false
    t.text   "data",        :null => false
  end

  create_table "openlayers_styles", :primary_key => "name", :force => true do |t|
    t.string "title",       :default => "", :null => false
    t.text   "description",                 :null => false
    t.text   "data"
  end

  add_index "openlayers_styles", ["name"], :name => "name"

  create_table "page_manager_handlers", :primary_key => "did", :force => true do |t|
    t.string  "name"
    t.string  "task",    :limit => 64
    t.string  "subtask", :limit => 64,         :default => "", :null => false
    t.string  "handler", :limit => 64
    t.integer "weight"
    t.text    "conf",    :limit => 2147483647,                 :null => false
  end

  add_index "page_manager_handlers", ["name"], :name => "name", :unique => true
  add_index "page_manager_handlers", ["task", "subtask", "weight"], :name => "fulltask"

  create_table "page_manager_pages", :primary_key => "pid", :force => true do |t|
    t.string "name"
    t.string "task",              :limit => 64,         :default => "page"
    t.string "admin_title"
    t.text   "admin_description", :limit => 2147483647
    t.string "path"
    t.text   "access",            :limit => 2147483647,                     :null => false
    t.text   "menu",              :limit => 2147483647,                     :null => false
    t.text   "arguments",         :limit => 2147483647,                     :null => false
    t.text   "conf",              :limit => 2147483647,                     :null => false
  end

  add_index "page_manager_pages", ["name"], :name => "name", :unique => true
  add_index "page_manager_pages", ["task"], :name => "task"

  create_table "page_manager_weights", :primary_key => "name", :force => true do |t|
    t.integer "weight"
  end

  add_index "page_manager_weights", ["name", "weight"], :name => "weights"

  create_table "permission", :primary_key => "pid", :force => true do |t|
    t.integer "rid",                        :default => 0, :null => false
    t.text    "perm", :limit => 2147483647
    t.integer "tid",                        :default => 0, :null => false
  end

  add_index "permission", ["rid"], :name => "rid"

  create_table "print_node_conf", :primary_key => "nid", :force => true do |t|
    t.integer "link",     :limit => 1, :default => 1, :null => false
    t.integer "comments", :limit => 1, :default => 1, :null => false
    t.integer "url_list", :limit => 1, :default => 1, :null => false
  end

  create_table "print_page_counter", :primary_key => "path", :force => true do |t|
    t.integer "totalcount", :limit => 8, :default => 0, :null => false
    t.integer "timestamp",               :default => 0, :null => false
  end

  create_table "print_pdf_node_conf", :primary_key => "nid", :force => true do |t|
    t.integer "link",     :limit => 1, :default => 1, :null => false
    t.integer "comments", :limit => 1, :default => 1, :null => false
    t.integer "url_list", :limit => 1, :default => 1, :null => false
  end

  create_table "print_pdf_page_counter", :primary_key => "path", :force => true do |t|
    t.integer "totalcount", :limit => 8, :default => 0, :null => false
    t.integer "timestamp",               :default => 0, :null => false
  end

  create_table "private", :primary_key => "nid", :force => true do |t|
    t.integer "private", :default => 0, :null => false
  end

  create_table "profile_fields", :primary_key => "fid", :force => true do |t|
    t.string  "title"
    t.string  "name",         :limit => 128, :default => "", :null => false
    t.text    "explanation"
    t.string  "category"
    t.string  "page"
    t.string  "type",         :limit => 128
    t.integer "weight",       :limit => 1,   :default => 0,  :null => false
    t.integer "required",     :limit => 1,   :default => 0,  :null => false
    t.integer "register",     :limit => 1,   :default => 0,  :null => false
    t.integer "visibility",   :limit => 1,   :default => 0,  :null => false
    t.integer "autocomplete", :limit => 1,   :default => 0,  :null => false
    t.text    "options"
  end

  add_index "profile_fields", ["category"], :name => "category"
  add_index "profile_fields", ["name"], :name => "name", :unique => true

  create_table "profile_values", :id => false, :force => true do |t|
    t.integer "fid",   :default => 0, :null => false
    t.integer "uid",   :default => 0, :null => false
    t.text    "value"
  end

  add_index "profile_values", ["fid"], :name => "fid"

  create_table "protected_nodes", :primary_key => "nid", :force => true do |t|
    t.string "passwd", :limit => 40, :default => "", :null => false
  end

  add_index "protected_nodes", ["passwd"], :name => "protected_passwd"

  create_table "role", :primary_key => "rid", :force => true do |t|
    t.string "name", :limit => 64, :default => "", :null => false
  end

  add_index "role", ["name"], :name => "name", :unique => true

  create_table "rules_rules", :primary_key => "name", :force => true do |t|
    t.binary "data", :limit => 2147483647
  end

  create_table "rules_scheduler", :primary_key => "tid", :force => true do |t|
    t.string   "set_name",   :default => "", :null => false
    t.datetime "date",                       :null => false
    t.text     "arguments"
    t.string   "identifier", :default => ""
  end

  add_index "rules_scheduler", ["date"], :name => "date"

  create_table "rules_sets", :primary_key => "name", :force => true do |t|
    t.binary "data", :limit => 2147483647
  end

  create_table "search_autocomplete_forms", :primary_key => "fid", :force => true do |t|
    t.string  "title",      :default => "", :null => false
    t.string  "selector",   :default => "", :null => false
    t.integer "weight",     :default => 0,  :null => false
    t.integer "enabled",    :default => 0,  :null => false
    t.integer "parent_fid", :default => 0,  :null => false
    t.integer "min_char",   :default => 3,  :null => false
    t.integer "max_sug",    :default => 15, :null => false
  end

  create_table "search_autocomplete_suggestions", :id => false, :force => true do |t|
    t.integer "sid",                             :default => 0,  :null => false
    t.integer "sug_fid",                         :default => 0,  :null => false
    t.integer "sug_enabled",                     :default => 0,  :null => false
    t.string  "sug_prefix",       :limit => 15,  :default => "", :null => false
    t.string  "sug_title",                       :default => "", :null => false
    t.string  "sug_name",                        :default => "", :null => false
    t.string  "sug_dependencies",                :default => "", :null => false
    t.integer "sug_weight",                      :default => 0,  :null => false
    t.string  "sug_query",        :limit => 512, :default => "", :null => false
  end

  create_table "search_dataset", :id => false, :force => true do |t|
    t.integer "sid",                           :default => 0, :null => false
    t.string  "type",    :limit => 16
    t.text    "data",    :limit => 2147483647,                :null => false
    t.integer "reindex",                       :default => 0, :null => false
  end

  add_index "search_dataset", ["sid", "type"], :name => "sid_type", :unique => true

  create_table "search_index", :id => false, :force => true do |t|
    t.string  "word",  :limit => 50, :default => "", :null => false
    t.integer "sid",                 :default => 0,  :null => false
    t.string  "type",  :limit => 16
    t.float   "score"
  end

  add_index "search_index", ["sid", "type"], :name => "sid_type"
  add_index "search_index", ["word", "sid", "type"], :name => "word_sid_type", :unique => true
  add_index "search_index", ["word"], :name => "word"

  create_table "search_node_links", :id => false, :force => true do |t|
    t.integer "sid",                           :default => 0,  :null => false
    t.string  "type",    :limit => 16,         :default => "", :null => false
    t.integer "nid",                           :default => 0,  :null => false
    t.text    "caption", :limit => 2147483647
  end

  add_index "search_node_links", ["nid"], :name => "nid"

  create_table "search_total", :primary_key => "word", :force => true do |t|
    t.float "count"
  end

  create_table "semaphore", :primary_key => "name", :force => true do |t|
    t.string "value",  :default => "", :null => false
    t.float  "expire",                 :null => false
  end

  add_index "semaphore", ["expire"], :name => "expire"

  create_table "sessions", :primary_key => "sid", :force => true do |t|
    t.integer "uid",                                             :null => false
    t.string  "hostname",  :limit => 128,        :default => "", :null => false
    t.integer "timestamp",                       :default => 0,  :null => false
    t.integer "cache",                           :default => 0,  :null => false
    t.text    "session",   :limit => 2147483647
  end

  add_index "sessions", ["timestamp"], :name => "timestamp"
  add_index "sessions", ["uid"], :name => "uid"

  create_table "simpleviews", :primary_key => "svid", :force => true do |t|
    t.string  "module",                  :default => "simpleviews", :null => false
    t.string  "path",                    :default => "",            :null => false
    t.string  "title",                   :default => "",            :null => false
    t.string  "header",                  :default => "",            :null => false
    t.string  "filter",   :limit => 128, :default => "all-posts",   :null => false
    t.string  "style",    :limit => 128, :default => "",            :null => false
    t.string  "sort",     :limit => 128, :default => "newest",      :null => false
    t.string  "argument", :limit => 128, :default => ""
    t.integer "rss",                     :default => 0,             :null => false
    t.integer "block",                   :default => 0,             :null => false
  end

  create_table "spamicide", :primary_key => "form_id", :force => true do |t|
    t.string  "form_field", :limit => 64, :default => "feed_me", :null => false
    t.integer "enabled",    :limit => 1,  :default => 0,         :null => false
    t.integer "removable",  :limit => 1,  :default => 1,         :null => false
  end

  create_table "stylizer", :primary_key => "sid", :force => true do |t|
    t.string "name"
    t.string "admin_title"
    t.text   "admin_description", :limit => 2147483647
    t.text   "settings",          :limit => 2147483647
  end

  add_index "stylizer", ["name"], :name => "name", :unique => true

  create_table "system", :primary_key => "filename", :force => true do |t|
    t.string  "name",                        :default => "", :null => false
    t.string  "type",                        :default => "", :null => false
    t.string  "owner",                       :default => "", :null => false
    t.integer "status",                      :default => 0,  :null => false
    t.integer "throttle",       :limit => 1, :default => 0,  :null => false
    t.integer "bootstrap",                   :default => 0,  :null => false
    t.integer "schema_version", :limit => 2, :default => -1, :null => false
    t.integer "weight",                      :default => 0,  :null => false
    t.text    "info"
  end

  add_index "system", ["type", "name"], :name => "type_name", :length => {"type"=>"12", "name"=>nil}
  add_index "system", ["type", "status", "bootstrap", "weight", "filename"], :name => "bootstrap", :length => {"type"=>"12", "status"=>nil, "bootstrap"=>nil, "weight"=>nil, "filename"=>nil}
  add_index "system", ["type", "status", "weight", "filename"], :name => "modules", :length => {"type"=>"12", "status"=>nil, "weight"=>nil, "filename"=>nil}

  create_table "tableofcontents_node_toc", :id => false, :force => true do |t|
    t.integer "nid",           :null => false
    t.integer "toc_automatic"
  end

  create_table "taxonomy_manager_merge", :primary_key => "merged_tid", :force => true do |t|
    t.integer "main_tid", :default => 0, :null => false
  end

  create_table "term_data", :primary_key => "tid", :force => true do |t|
    t.integer "vid",                               :default => 0,  :null => false
    t.string  "name",                              :default => "", :null => false
    t.text    "description", :limit => 2147483647
    t.integer "weight",      :limit => 1,          :default => 0,  :null => false
  end

  add_index "term_data", ["vid", "name"], :name => "vid_name"
  add_index "term_data", ["vid", "weight", "name"], :name => "taxonomy_tree"

  create_table "term_hierarchy", :id => false, :force => true do |t|
    t.integer "tid",    :default => 0, :null => false
    t.integer "parent", :default => 0, :null => false
  end

  add_index "term_hierarchy", ["parent"], :name => "parent"

  create_table "term_node", :id => false, :force => true do |t|
    t.integer "nid", :default => 0, :null => false
    t.integer "vid", :default => 0, :null => false
    t.integer "tid", :default => 0, :null => false
  end

  add_index "term_node", ["nid"], :name => "nid"
  add_index "term_node", ["vid"], :name => "vid"

  create_table "term_relation", :primary_key => "trid", :force => true do |t|
    t.integer "tid1", :default => 0, :null => false
    t.integer "tid2", :default => 0, :null => false
  end

  add_index "term_relation", ["tid1", "tid2"], :name => "tid1_tid2", :unique => true
  add_index "term_relation", ["tid2"], :name => "tid2"

  create_table "term_synonym", :primary_key => "tsid", :force => true do |t|
    t.integer "tid",  :default => 0,  :null => false
    t.string  "name", :default => "", :null => false
  end

  add_index "term_synonym", ["name", "tid"], :name => "name_tid"
  add_index "term_synonym", ["tid"], :name => "tid"

  create_table "to_do", :primary_key => "vid", :force => true do |t|
    t.integer "nid",                           :default => 0, :null => false
    t.integer "item_status",                   :default => 0
    t.integer "priority",                      :default => 0
    t.integer "start_date"
    t.integer "deadline"
    t.integer "date_finished"
    t.integer "deadline_event",   :limit => 1, :default => 0
    t.integer "auto_close",       :limit => 1, :default => 0
    t.integer "mark_permissions", :limit => 1, :default => 0
  end

  add_index "to_do", ["auto_close", "deadline"], :name => "auto_close"
  add_index "to_do", ["deadline"], :name => "deadline"

  create_table "to_do_assigned_users", :id => false, :force => true do |t|
    t.integer "nid", :default => 0, :null => false
    t.integer "vid", :default => 0, :null => false
    t.integer "uid", :default => 1, :null => false
  end

  create_table "to_do_block_user_preferences", :id => false, :force => true do |t|
    t.integer "uid",                                     :default => 0, :null => false
    t.integer "sidebar_items",                           :default => 5
    t.integer "low_priority_items_display", :limit => 1, :default => 1
  end

  create_table "token_custom", :primary_key => "tkid", :force => true do |t|
    t.string "id",          :limit => 100,        :null => false
    t.string "description",                       :null => false
    t.string "type",        :limit => 32,         :null => false
    t.text   "php",         :limit => 2147483647, :null => false
  end

  create_table "trigger_assignments", :id => false, :force => true do |t|
    t.string  "hook",   :limit => 32, :default => "", :null => false
    t.string  "op",     :limit => 32, :default => "", :null => false
    t.string  "aid",                  :default => "", :null => false
    t.integer "weight",               :default => 0,  :null => false
  end

  create_table "upload", :id => false, :force => true do |t|
    t.integer "fid",                      :default => 0,  :null => false
    t.integer "nid",                      :default => 0,  :null => false
    t.integer "vid",                      :default => 0,  :null => false
    t.string  "description",              :default => "", :null => false
    t.integer "list",        :limit => 1, :default => 0,  :null => false
    t.integer "weight",      :limit => 1, :default => 0,  :null => false
  end

  add_index "upload", ["fid"], :name => "fid"
  add_index "upload", ["nid"], :name => "nid"

  create_table "url_alias", :primary_key => "pid", :force => true do |t|
    t.string "src",      :limit => 128, :default => "", :null => false
    t.string "dst",      :limit => 128, :default => "", :null => false
    t.string "language", :limit => 12,  :default => "", :null => false
  end

  add_index "url_alias", ["dst", "language", "pid"], :name => "dst_language_pid", :unique => true
  add_index "url_alias", ["src", "language", "pid"], :name => "src_language_pid"

  create_table "users", :primary_key => "uid", :force => true do |t|
    t.string  "name",             :limit => 60,         :default => "", :null => false
    t.string  "pass",             :limit => 32,         :default => "", :null => false
    t.string  "mail",             :limit => 64,         :default => ""
    t.integer "mode",             :limit => 1,          :default => 0,  :null => false
    t.integer "sort",             :limit => 1,          :default => 0
    t.integer "threshold",        :limit => 1,          :default => 0
    t.string  "theme",                                  :default => "", :null => false
    t.string  "signature",                              :default => "", :null => false
    t.integer "signature_format", :limit => 2,          :default => 0,  :null => false
    t.integer "created",                                :default => 0,  :null => false
    t.integer "access",                                 :default => 0,  :null => false
    t.integer "login",                                  :default => 0,  :null => false
    t.integer "status",           :limit => 1,          :default => 0,  :null => false
    t.string  "timezone",         :limit => 8
    t.string  "language",         :limit => 12,         :default => "", :null => false
    t.string  "picture",                                :default => "", :null => false
    t.string  "init",             :limit => 64,         :default => ""
    t.text    "data",             :limit => 2147483647
    t.integer "timezone_id",                            :default => 0,  :null => false
    t.string  "timezone_name",    :limit => 50,         :default => "", :null => false
  end

  add_index "users", ["access"], :name => "access"
  add_index "users", ["created"], :name => "created"
  add_index "users", ["mail"], :name => "mail"
  add_index "users", ["name"], :name => "name", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "uid", :default => 0, :null => false
    t.integer "rid", :default => 0, :null => false
  end

  add_index "users_roles", ["rid"], :name => "rid"

  create_table "variable", :primary_key => "name", :force => true do |t|
    t.text "value", :limit => 2147483647, :null => false
  end

  create_table "views_display", :id => false, :force => true do |t|
    t.integer "vid",                                   :default => 0,  :null => false
    t.string  "id",              :limit => 64,         :default => "", :null => false
    t.string  "display_title",   :limit => 64,         :default => "", :null => false
    t.string  "display_plugin",  :limit => 64,         :default => "", :null => false
    t.integer "position",                              :default => 0
    t.text    "display_options", :limit => 2147483647
  end

  add_index "views_display", ["vid", "position"], :name => "vid"

  create_table "views_object_cache", :id => false, :force => true do |t|
    t.string  "sid",     :limit => 64
    t.string  "name",    :limit => 32
    t.string  "obj",     :limit => 32
    t.integer "updated",                       :default => 0, :null => false
    t.text    "data",    :limit => 2147483647
  end

  add_index "views_object_cache", ["sid", "obj", "name"], :name => "sid_obj_name"
  add_index "views_object_cache", ["updated"], :name => "updated"

  create_table "views_view", :primary_key => "vid", :force => true do |t|
    t.string  "name",         :limit => 32, :default => "", :null => false
    t.string  "description",                :default => ""
    t.string  "tag",                        :default => ""
    t.binary  "view_php"
    t.string  "base_table",   :limit => 64, :default => "", :null => false
    t.integer "is_cacheable", :limit => 1,  :default => 0
  end

  add_index "views_view", ["name"], :name => "name", :unique => true

  create_table "vocabulary", :primary_key => "vid", :force => true do |t|
    t.string  "name",                              :default => "", :null => false
    t.text    "description", :limit => 2147483647
    t.string  "help",                              :default => "", :null => false
    t.integer "relations",   :limit => 1,          :default => 0,  :null => false
    t.integer "hierarchy",   :limit => 1,          :default => 0,  :null => false
    t.integer "multiple",    :limit => 1,          :default => 0,  :null => false
    t.integer "required",    :limit => 1,          :default => 0,  :null => false
    t.integer "tags",        :limit => 1,          :default => 0,  :null => false
    t.string  "module",                            :default => "", :null => false
    t.integer "weight",      :limit => 1,          :default => 0,  :null => false
  end

  add_index "vocabulary", ["weight", "name"], :name => "list"

  create_table "vocabulary_node_types", :id => false, :force => true do |t|
    t.integer "vid",                :default => 0,  :null => false
    t.string  "type", :limit => 32, :default => "", :null => false
  end

  add_index "vocabulary_node_types", ["vid"], :name => "vid"

  create_table "watchdog", :primary_key => "wid", :force => true do |t|
    t.integer "uid",                             :default => 0,  :null => false
    t.string  "type",      :limit => 16,         :default => "", :null => false
    t.text    "message",   :limit => 2147483647,                 :null => false
    t.text    "variables", :limit => 2147483647,                 :null => false
    t.integer "severity",  :limit => 1,          :default => 0,  :null => false
    t.string  "link",                            :default => "", :null => false
    t.text    "location",                                        :null => false
    t.text    "referer"
    t.string  "hostname",  :limit => 128,        :default => "", :null => false
    t.integer "timestamp",                       :default => 0,  :null => false
  end

  add_index "watchdog", ["type"], :name => "type"

  create_table "wysiwyg", :primary_key => "format", :force => true do |t|
    t.string "editor",   :limit => 128, :default => "", :null => false
    t.text   "settings"
  end

end
