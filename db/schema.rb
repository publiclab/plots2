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

# Could not dump table "content_field_bbox" because of following StandardError
#   Unknown type 'geometry' for column 'field_bbox_geo'
  create_table "content_field_bbox", :id => false, :force => true do |t|
    t.integer "vid",                                   :default => 0, :null => false
    t.integer "nid",                                   :default => 0, :null => false
    t.integer "delta",                                 :default => 0, :null => false
    t.point "geometry",                                 :null => true, , :srid => 123, :with_z => true
  end

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

  create_table "content_field_map", :id => false, :force => true do |t|
    t.integer "vid",                                            :default => 0, :null => false
    t.integer "nid",                                            :default => 0, :null => false
    t.text    "field_map_openlayers_wkt", :limit => 2147483647
    t.integer "delta",                                          :default => 0, :null => false
  end

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
  end

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

  create_table "profile_values", :id => false, :force => true do |t|
    t.integer "fid",   :default => 0, :null => false
    t.integer "uid",   :default => 0, :null => false
    t.text    "value"
  end

  create_table "protected_nodes", :primary_key => "nid", :force => true do |t|
    t.string "passwd", :limit => 40, :default => "", :null => false
  end

  create_table "term_data", :primary_key => "tid", :force => true do |t|
    t.integer "vid",                               :default => 0,  :null => false
    t.string  "name",                              :default => "", :null => false
    t.text    "description", :limit => 2147483647
    t.integer "weight",      :limit => 1,          :default => 0,  :null => false
  end

  create_table "term_node", :id => false, :force => true do |t|
    t.integer "nid", :default => 0, :null => false
    t.integer "vid", :default => 0, :null => false
    t.integer "tid", :default => 0, :null => false
  end

  create_table "term_relation", :primary_key => "trid", :force => true do |t|
    t.integer "tid1", :default => 0, :null => false
    t.integer "tid2", :default => 0, :null => false
  end

  add_index "term_relation", ["tid1", "tid2"], :name => "tid1_tid2", :unique => true
  add_index "term_relation", ["tid2"], :name => "tid2"

  create_table "url_alias", :primary_key => "pid", :force => true do |t|
    t.string "src",      :limit => 128, :default => "", :null => false
    t.string "dst",      :limit => 128, :default => "", :null => false
    t.string "language", :limit => 12,  :default => "", :null => false
  end

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

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "uid", :default => 0, :null => false
    t.integer "rid", :default => 0, :null => false
  end

end
