class DropContentFieldBbox < ActiveRecord::Migration
  def up
    drop_table :content_field_bbox if table_exists? "content_field_bbox"
    rename_index :community_tags, 'nid', 'index_community_tags_nid' #if index_exists?(:community_tags, 'nid')
    rename_index "comments", "nid", "index_comments_nid"
    rename_index "comments", "pid", "index_comments_pid"
    rename_index "comments", "status", "index_comments_status"
    rename_index "community_tags", "nid", "index_community_tags_nid"
    rename_index "community_tags", "tid", "index_community_tags_tid"
    rename_index "community_tags", "uid", "index_community_tags_uid"
    rename_index "content_field_image_gallery", "nid", "index_content_field_image_gallery_nid"
    rename_index "content_field_main_image", "nid", "index_content_field_main_image_nid"
    rename_index "content_field_map_editor", "nid", "index_content_field_map_editor_nid"
    rename_index "content_field_mappers", "nid", "index_content_field_mappers_nid"
    rename_index "content_type_map", "nid", "index_content_type_map_nid"
    rename_index "files", "status", "index_files_status"
    rename_index "files", "timestamp", "index_files_timestamp"
    rename_index "files", "uid", "index_files_uid"
    rename_index "node", "tnid", "index_node_tnid"
    rename_index "node", "translate", "index_node_translate"
    rename_index "node", "uid", "index_node_uid"
    rename_index "node", "vid", "index_node_vid"
    rename_index "node_revisions", "nid", "index_node_revisions_nid"
    rename_index "node_revisions", "uid", "index_node_revisions_uid"
    rename_index "profile_fields", "category", "index_profile_fields_category"
    rename_index "profile_fields", "name", "index_profile_fields_name"
    rename_index "profile_values", "fid", "index_profile_values_fid"
    rename_index "term_data", "vid_name", "index_term_data_vid_name"
    rename_index "term_data", "taxonomy_tree", "index_vid_weight_name" 
    rename_index "term_node", "nid", "index_term_node_nid"
    rename_index "term_node", "vid", "index_term_node_vid"
    rename_index "upload", "fid", "index_upload_fid"
    rename_index "upload", "nid", "index_upload_nid"
    rename_index "users", "access", "index_users_access"
    rename_index "users", "created", "index_users_created"
    rename_index "users", "mail", "index_users_mail"
    rename_index "users", "name", "index_users_name"

    change_column :node_revisions, :teaser, :text, null: true
    change_column :node_revisions, :log, :text, null: true
    change_column :rusers, :persistence_token, :string, null: true
  end

  def down
  end
end
