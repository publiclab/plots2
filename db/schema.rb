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

ActiveRecord::Schema.define(:version => 20140507095348) do

  create_table "comments", :primary_key => "cid", :options=>'ENGINE=MyISAM', :force => true do |t|
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
  end

  add_index "comments", ["nid"], :name => "nid"
  add_index "comments", ["pid"], :name => "pid"
  add_index "comments", ["status"], :name => "status"

  create_table "community_tags", :id => false, :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "tid",  :default => 0, :null => false
    t.integer "nid",  :default => 0, :null => false
    t.integer "uid",  :default => 0, :null => false
    t.integer "date", :default => 0, :null => false
  end

  add_index "community_tags", ["nid"], :name => "nid"
  add_index "community_tags", ["tid", "nid"], :name => "tid_nid"
  add_index "community_tags", ["tid"], :name => "tid"
  add_index "community_tags", ["uid"], :name => "uid"

  create_table "content_field_bbox", :id => false, :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer  "vid",                           :default => 0, :null => false
    t.integer  "nid",                           :default => 0, :null => false
    t.integer  "delta",                         :default => 0, :null => false
    t.geometry "field_bbox_geo", :limit => nil
  end

  add_index "content_field_bbox", ["nid"], :name => "nid"

  create_table "content_field_image_gallery", :id => false, :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "vid",                                   :default => 0, :null => false
    t.integer "nid",                                   :default => 0, :null => false
    t.integer "delta",                                 :default => 0, :null => false
    t.integer "field_image_gallery_fid"
    t.integer "field_image_gallery_list", :limit => 1
    t.text    "field_image_gallery_data"
  end

  add_index "content_field_image_gallery", ["nid"], :name => "nid"

  create_table "content_field_main_image", :primary_key => "vid", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "nid",                                :default => 0, :null => false
    t.integer "field_main_image_fid"
    t.integer "field_main_image_list", :limit => 1
    t.text    "field_main_image_data"
  end

  add_index "content_field_main_image", ["nid"], :name => "nid"

  create_table "content_field_map_editor", :id => false, :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "vid",                                          :default => 0, :null => false
    t.integer "nid",                                          :default => 0, :null => false
    t.integer "delta",                                        :default => 0, :null => false
    t.text    "field_map_editor_value", :limit => 2147483647
  end

  add_index "content_field_map_editor", ["nid"], :name => "nid"

  create_table "content_field_mappers", :id => false, :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "vid",                                       :default => 0, :null => false
    t.integer "nid",                                       :default => 0, :null => false
    t.integer "delta",                                     :default => 0, :null => false
    t.text    "field_mappers_value", :limit => 2147483647
  end

  add_index "content_field_mappers", ["nid"], :name => "nid"

  create_table "content_type_map", :primary_key => "vid", :options=>'ENGINE=MyISAM', :force => true do |t|
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
    t.string  "authorship"
  end

  add_index "content_type_map", ["nid"], :name => "nid"

  create_table "files", :primary_key => "fid", :options=>'ENGINE=MyISAM', :force => true do |t|
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

  create_table "images", :force => true do |t|
    t.string   "title"
    t.integer  "uid"
    t.integer  "nid"
    t.string   "notes"
    t.integer  "version",            :default => 0
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "node", :primary_key => "nid", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "vid",                                       :default => 0,  :null => false
    t.string  "type",                        :limit => 32, :default => "", :null => false
    t.string  "language",                    :limit => 12, :default => "", :null => false
    t.string  "title",                                     :default => "", :null => false
    t.integer "uid",                                       :default => 0,  :null => false
    t.integer "status",                                    :default => 1,  :null => false
    t.integer "created",                                   :default => 0,  :null => false
    t.integer "changed",                                   :default => 0,  :null => false
    t.integer "comment",                                   :default => 0,  :null => false
    t.integer "promote",                                   :default => 0,  :null => false
    t.integer "moderate",                                  :default => 0,  :null => false
    t.integer "sticky",                                    :default => 0,  :null => false
    t.integer "tnid",                                      :default => 0,  :null => false
    t.integer "translate",                                 :default => 0,  :null => false
    t.integer "cached_likes",                              :default => 0
    t.integer "drupal_comments_count",                     :default => 0
    t.integer "drupal_node_revisions_count",               :default => 0
    t.string  "dst"
  end

  add_index "node", ["changed"], :name => "node_changed"
  add_index "node", ["created"], :name => "node_created"
  add_index "node", ["moderate"], :name => "node_moderate"
  add_index "node", ["promote", "status"], :name => "node_promote_status"
  add_index "node", ["status", "type", "nid"], :name => "node_status_type"
  add_index "node", ["title", "type"], :name => "node_title_type"
  add_index "node", ["tnid"], :name => "tnid"
  add_index "node", ["translate"], :name => "translate"
  add_index "node", ["type"], :name => "node_type"
  add_index "node", ["uid"], :name => "uid"
  add_index "node", ["vid"], :name => "vid"

  create_table "node_access", :id => false, :force => true do |t|
    t.integer "nid",                       :default => 0,  :null => false
    t.integer "gid",                       :default => 0,  :null => false
    t.string  "realm",                     :default => "", :null => false
    t.integer "grant_view",   :limit => 1, :default => 0,  :null => false
    t.integer "grant_update", :limit => 1, :default => 0,  :null => false
    t.integer "grant_delete", :limit => 1, :default => 0,  :null => false
  end

  create_table "node_counter", :primary_key => "nid", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "totalcount", :limit => 8, :default => 0, :null => false
    t.integer "daycount",   :limit => 3, :default => 0, :null => false
    t.integer "timestamp",               :default => 0, :null => false
  end

  create_table "node_revisions", :primary_key => "vid", :options=>'ENGINE=MyISAM', :force => true do |t|
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

  create_table "node_selections", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "nid"
    t.boolean "following", :default => false
    t.boolean "liking",    :default => false
  end

  add_index "node_selections", ["user_id", "nid"], :name => "index_node_selections_on_user_id_and_nid"

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
  add_index "profile_fields", ["name"], :name => "name"

  create_table "profile_values", :id => false, :force => true do |t|
    t.integer "fid",   :default => 0, :null => false
    t.integer "uid",   :default => 0, :null => false
    t.text    "value"
  end

  add_index "profile_values", ["fid"], :name => "fid"

  create_table "rsessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "rsessions", ["session_id"], :name => "index_rsessions_on_session_id"
  add_index "rsessions", ["updated_at"], :name => "index_rsessions_on_updated_at"

  create_table "rusers", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                       :null => false
    t.integer  "login_count",        :default => 0,       :null => false
    t.integer  "failed_login_count", :default => 0,       :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "openid_identifier"
    t.string   "role",               :default => "basic"
    t.string   "reset_key"
  end

  create_table "tag_selections", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "tid"
    t.boolean "following", :default => false
  end

  add_index "tag_selections", ["user_id", "tid"], :name => "index_tag_selections_on_user_id_and_tid"

  create_table "tags", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.string   "user_id"
    t.string   "type"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "term_data", :primary_key => "tid", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "vid",                               :default => 0,  :null => false
    t.string  "name",                              :default => "", :null => false
    t.text    "description", :limit => 2147483647
    t.integer "weight",      :limit => 1,          :default => 0,  :null => false
  end

  add_index "term_data", ["vid", "name"], :name => "vid_name"
  add_index "term_data", ["vid", "weight", "name"], :name => "taxonomy_tree"

  create_table "term_node", :id => false, :options=>'ENGINE=MyISAM', :force => true do |t|
    t.integer "nid", :default => 0, :null => false
    t.integer "vid", :default => 0, :null => false
    t.integer "tid", :default => 0, :null => false
  end

  add_index "term_node", ["nid"], :name => "nid"
  add_index "term_node", ["vid"], :name => "vid"

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

  create_table "url_alias", :primary_key => "pid", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.string "src",      :limit => 128, :default => "", :null => false
    t.string "dst",      :limit => 128, :default => "", :null => false
    t.string "language", :limit => 12,  :default => "", :null => false
  end

  add_index "url_alias", ["dst", "language", "pid"], :name => "dst_language_pid"
  add_index "url_alias", ["src", "language", "pid"], :name => "src_language_pid"

  create_table "user_selections", :id => false, :force => true do |t|
    t.integer "self_id"
    t.integer "other_id"
    t.boolean "following", :default => false
  end

  add_index "user_selections", ["self_id", "other_id"], :name => "index_user_selections_on_self_id_and_other_id"

  create_table "users", :primary_key => "uid", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.string  "name",             :limit => 60,                                         :default => "",  :null => false
    t.string  "pass",             :limit => 32,                                         :default => "",  :null => false
    t.string  "mail",             :limit => 64,                                         :default => ""
    t.integer "mode",             :limit => 1,                                          :default => 0,   :null => false
    t.integer "sort",             :limit => 1,                                          :default => 0
    t.integer "threshold",        :limit => 1,                                          :default => 0
    t.string  "theme",                                                                  :default => "",  :null => false
    t.string  "signature",                                                              :default => "",  :null => false
    t.integer "signature_format", :limit => 2,                                          :default => 0,   :null => false
    t.integer "created",                                                                :default => 0,   :null => false
    t.integer "access",                                                                 :default => 0,   :null => false
    t.integer "login",                                                                  :default => 0,   :null => false
    t.integer "status",           :limit => 1,                                          :default => 0,   :null => false
    t.string  "timezone",         :limit => 8
    t.string  "language",         :limit => 12,                                         :default => "",  :null => false
    t.string  "picture",                                                                :default => "",  :null => false
    t.string  "init",             :limit => 64,                                         :default => ""
    t.text    "data",             :limit => 2147483647
    t.integer "timezone_id",                                                            :default => 0,   :null => false
    t.string  "timezone_name",    :limit => 50,                                         :default => "",  :null => false
    t.decimal "lat",                                    :precision => 20, :scale => 10, :default => 0.0
    t.decimal "lon",                                    :precision => 20, :scale => 10, :default => 0.0
  end

  add_index "users", ["access"], :name => "access"
  add_index "users", ["created"], :name => "created"
  add_index "users", ["mail"], :name => "mail"
  add_index "users", ["name"], :name => "name"

end
