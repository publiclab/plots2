class DrupalSchema < ActiveRecord::Migration
  def up

  create_table "comments", :primary_key => "cid", :options=>'ENGINE=MyISAM' do |t|
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

  create_table "community_tags", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer "tid",  :default => 0, :null => false
    t.integer "nid",  :default => 0, :null => false
    t.integer "uid",  :default => 0, :null => false
    t.integer "date", :default => 0, :null => false
  end

  add_index "community_tags", ["nid"], :name => "nid"
  add_index "community_tags", ["tid", "nid"], :name => "tid_nid"
  add_index "community_tags", ["tid"], :name => "tid"
  add_index "community_tags", ["uid"], :name => "uid"

  create_table "content_field_bbox", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer  "vid",                           :default => 0, :null => false
    t.integer  "nid",                           :default => 0, :null => false
    t.integer  "delta",                         :default => 0, :null => false
    t.geometry "field_bbox_geo", :limit => nil
  end

  add_index "content_field_bbox", ["nid"], :name => "nid"

  create_table "content_field_image_gallery", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer "vid",                                   :default => 0, :null => false
    t.integer "nid",                                   :default => 0, :null => false
    t.integer "delta",                                 :default => 0, :null => false
    t.integer "field_image_gallery_fid"
    t.integer "field_image_gallery_list", :limit => 1
    t.text    "field_image_gallery_data"
  end

  add_index "content_field_image_gallery", ["nid"], :name => "nid"

  create_table "content_field_main_image", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid",                                :default => 0, :null => false
    t.integer "field_main_image_fid"
    t.integer "field_main_image_list", :limit => 1
    t.text    "field_main_image_data"
  end

  add_index "content_field_main_image", ["nid"], :name => "nid"

  create_table "content_field_map", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer "vid",                                            :default => 0, :null => false
    t.integer "nid",                                            :default => 0, :null => false
    t.text    "field_map_openlayers_wkt", :limit => 2147483647
    t.integer "delta",                                          :default => 0, :null => false
  end

  add_index "content_field_map", ["nid"], :name => "nid"

  create_table "content_field_map_editor", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer "vid",                                          :default => 0, :null => false
    t.integer "nid",                                          :default => 0, :null => false
    t.integer "delta",                                        :default => 0, :null => false
    t.text    "field_map_editor_value", :limit => 2147483647
  end

  add_index "content_field_map_editor", ["nid"], :name => "nid"

  create_table "content_field_mappers", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer "vid",                                       :default => 0, :null => false
    t.integer "nid",                                       :default => 0, :null => false
    t.integer "delta",                                     :default => 0, :null => false
    t.text    "field_mappers_value", :limit => 2147483647
  end

  add_index "content_field_mappers", ["nid"], :name => "nid"

  create_table "content_group", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.string  "group_type", :limit => 32,       :default => "standard", :null => false
    t.string  "type_name",  :limit => 32,       :default => "",         :null => false
    t.string  "group_name", :limit => 32,       :default => "",         :null => false
    t.string  "label",                          :default => "",         :null => false
    t.text    "settings",   :limit => 16777215,                         :null => false
    t.integer "weight",                         :default => 0,          :null => false
  end

  create_table "content_group_fields", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.string "type_name",  :limit => 32, :default => "", :null => false
    t.string "group_name", :limit => 32, :default => "", :null => false
    t.string "field_name", :limit => 32, :default => "", :null => false
  end

  create_table "content_node_field", :primary_key => "field_name", :options=>'ENGINE=MyISAM' do |t|
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

  create_table "content_node_field_instance", :id => false, :options=>'ENGINE=MyISAM' do |t|
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

  create_table "content_type_map", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
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

  create_table "content_type_note", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_note", ["nid"], :name => "nid"

  create_table "content_type_page", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid",             :default => 0, :null => false
    t.integer "field_toc_value"
  end

  add_index "content_type_page", ["nid"], :name => "nid"

  create_table "content_type_place", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid",                                          :default => 0, :null => false
    t.integer "field_host_logo_fid"
    t.integer "field_host_logo_list",   :limit => 1
    t.text    "field_host_logo_data"
    t.text    "field_host_name_value",  :limit => 2147483647
    t.integer "field_host_name_format"
  end

  add_index "content_type_place", ["nid"], :name => "nid"

  create_table "content_type_report", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_report", ["nid"], :name => "nid"

  create_table "content_type_tool", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid", :default => 0, :null => false
  end

  add_index "content_type_tool", ["nid"], :name => "nid"

  create_table "context", :primary_key => "name", :options=>'ENGINE=MyISAM' do |t|
    t.string  "description",    :default => "", :null => false
    t.string  "tag",            :default => "", :null => false
    t.text    "conditions"
    t.text    "reactions"
    t.integer "condition_mode", :default => 0
  end

  create_table "files", :primary_key => "fid", :options=>'ENGINE=MyISAM' do |t|
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

  create_table "node", :primary_key => "nid", :options=>'ENGINE=MyISAM' do |t|
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

  create_table "node_comment_statistics", :primary_key => "nid", :force => true do |t|
    t.integer "last_comment_timestamp",               :default => 0, :null => false
    t.string  "last_comment_name",      :limit => 60
    t.integer "last_comment_uid",                     :default => 0, :null => false
    t.integer "comment_count",                        :default => 0, :null => false
  end

  add_index "node_comment_statistics", ["last_comment_timestamp"], :name => "node_comment_timestamp"

  create_table "node_counter", :primary_key => "nid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "totalcount", :limit => 8, :default => 0, :null => false
    t.integer "daycount",   :limit => 3, :default => 0, :null => false
    t.integer "timestamp",               :default => 0, :null => false
  end

  create_table "node_images", :options=>'ENGINE=MyISAM' do |t|
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

  create_table "node_revisions", :primary_key => "vid", :options=>'ENGINE=MyISAM' do |t|
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


  create_table "term_data", :primary_key => "tid", :options=>'ENGINE=MyISAM' do |t|
    t.integer "vid",                               :default => 0,  :null => false
    t.string  "name",                              :default => "", :null => false
    t.text    "description", :limit => 2147483647
    t.integer "weight",      :limit => 1,          :default => 0,  :null => false
  end

  add_index "term_data", ["vid", "name"], :name => "vid_name"
  add_index "term_data", ["vid", "weight", "name"], :name => "taxonomy_tree"

  create_table "term_node", :id => false, :options=>'ENGINE=MyISAM' do |t|
    t.integer "nid", :default => 0, :null => false
    t.integer "vid", :default => 0, :null => false
    t.integer "tid", :default => 0, :null => false
  end

  add_index "term_node", ["nid"], :name => "nid"
  add_index "term_node", ["vid"], :name => "vid"

  create_table "url_alias", :primary_key => "pid", :options=>'ENGINE=MyISAM' do |t|
    t.string "src",      :limit => 128, :default => "", :null => false
    t.string "dst",      :limit => 128, :default => "", :null => false
    t.string "language", :limit => 12,  :default => "", :null => false
  end

  add_index "url_alias", ["dst", "language", "pid"], :name => "dst_language_pid"
  add_index "url_alias", ["src", "language", "pid"], :name => "src_language_pid"

  create_table "users", :primary_key => "uid", :options=>'ENGINE=MyISAM' do |t|
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

  def down
    drop_table "comments"
    drop_table "community_tags"
    drop_table "content_field_bbox"
    drop_table "content_field_image_gallery"
    drop_table "content_field_main_image"
    drop_table "content_field_map"
    drop_table "content_field_map_editor"
    drop_table "content_field_mappers"
    drop_table "content_group"
    drop_table "content_group_fields"
    drop_table "content_node_field"
    drop_table "content_node_field_instance"
    drop_table "content_type_map"
    drop_table "content_type_note"
    drop_table "content_type_page"
    drop_table "content_type_place"
    drop_table "content_type_report"
    drop_table "content_type_tool"
    drop_table "context"
    drop_table "files"
    drop_table "node"
    drop_table "node_counter"
    drop_table "node_images"
    drop_table "node_revisions"
    drop_table "term_data"
    drop_table "term_node"
    drop_table "url_alias"
    drop_table "users"
  end

end
