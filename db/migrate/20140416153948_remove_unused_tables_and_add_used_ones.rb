class RemoveUnusedTablesAndAddUsedOnes < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("DROP VIEW IF EXISTS view_node_like_count")
    drop_table :content_field_map
    drop_table :content_group
    drop_table :content_group_fields
    drop_table :content_node_field
    drop_table :content_node_field_instance
    drop_table :content_type_note
    drop_table :content_type_page
    drop_table :content_type_place
    drop_table :content_type_report
    drop_table :content_type_tool
    drop_table :context
    drop_table :node_images

    unless table_exists? "node_access"
      create_table "node_access", :id => false do |t|
        t.integer "nid",                       :default => 0,  :null => false
        t.integer "gid",                       :default => 0,  :null => false
        t.string  "realm",                     :default => "", :null => false
        t.integer "grant_view",   :limit => 1, :default => 0,  :null => false
        t.integer "grant_update", :limit => 1, :default => 0,  :null => false
        t.integer "grant_delete", :limit => 1, :default => 0,  :null => false
      end
    end

    unless table_exists? "profile_fields"
      create_table "profile_fields", :primary_key => "fid" do |t|
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
    end

    unless index_exists? "profile_fields", :category, name: "category"
      add_index "profile_fields", ["category"], :name => "category"
    end

    unless index_exists? "profile_fields", :name, name: "name"
      add_index "profile_fields", ["name"], :name => "name"
    end

    unless table_exists? "profile_values"
      create_table "profile_values", :id => false do |t|
        t.integer "fid",   :default => 0, :null => false
        t.integer "uid",   :default => 0, :null => false
        t.text    "value"
      end
    end

    unless index_exists? "profile_values", :fid, name: "fid"
      add_index "profile_values", ["fid"], :name => "fid"
    end

    unless table_exists? "upload"
      create_table "upload", :id => false do |t|
        t.integer "fid",                      :default => 0,  :null => false
        t.integer "nid",                      :default => 0,  :null => false
        t.integer "vid",                      :default => 0,  :null => false
        t.string  "description",              :default => "", :null => false
        t.integer "list",        :limit => 1, :default => 0,  :null => false
        t.integer "weight",      :limit => 1, :default => 0,  :null => false
      end
    end

    unless index_exists? "upload", :fid, name: "fid"
      add_index "upload", ["fid"], :name => "fid"
    end

    unless index_exists? "upload", :nid, name: "nid"
      add_index "upload", ["nid"], :name => "nid"
    end
    #
    # drop old tables
    drop_table :access if table_exists? :access
    drop_table :accesslog if table_exists? :accesslog
    drop_table :actions if table_exists? :actions
    drop_table :actions_aid if table_exists? :actions_aid
    drop_table :activity if table_exists? :activity
    drop_table :activity_access if table_exists? :activity_access
    drop_table :activity_comments if table_exists? :activity_comments
    drop_table :activity_comments_stats if table_exists? :activity_comments_stats
    drop_table :activity_messages if table_exists? :activity_messages
    drop_table :activity_targets if table_exists? :activity_targets
    drop_table :advanced_help_index if table_exists? :advanced_help_index
    drop_table :aggregator_category if table_exists? :aggregator_category
    drop_table :aggregator_category_feed if table_exists? :aggregator_category_feed
    drop_table :aggregator_category_item if table_exists? :aggregator_category_item
    drop_table :aggregator_feed if table_exists? :aggregator_feed
    drop_table :aggregator_item if table_exists? :aggregator_item
    drop_table :antispam_counter if table_exists? :antispam_counter
    drop_table :antispam_moderator if table_exists? :antispam_moderator
    drop_table :antispam_spam_marks if table_exists? :antispam_spam_marks
    drop_table :authmap if table_exists? :authmap
    drop_table :autoload_registry if table_exists? :autoload_registry
    drop_table :autoload_registry_file if table_exists? :autoload_registry_file
    drop_table :backup_migrate_destinations if table_exists? :backup_migrate_destinations
    drop_table :backup_migrate_profiles if table_exists? :backup_migrate_profiles
    drop_table :backup_migrate_schedules if table_exists? :backup_migrate_schedules
    drop_table :batch if table_exists? :batch
    drop_table :blocks if table_exists? :blocks
    drop_table :blocks_roles if table_exists? :blocks_roles
    drop_table :book if table_exists? :book
    drop_table :boost_cache if table_exists? :boost_cache
    drop_table :boost_cache_relationships if table_exists? :boost_cache_relationships
    drop_table :boost_cache_settings if table_exists? :boost_cache_settings
    drop_table :boost_crawler if table_exists? :boost_crawler
    drop_table :boxes if table_exists? :boxes
    drop_table :cache if table_exists? :cache
    drop_table :cache_block if table_exists? :cache_block
    drop_table :cache_content if table_exists? :cache_content
    drop_table :cache_filter if table_exists? :cache_filter
    drop_table :cache_form if table_exists? :cache_form
    drop_table :cache_gravatar if table_exists? :cache_gravatar
    drop_table :cache_menu if table_exists? :cache_menu
    drop_table :cache_mollom if table_exists? :cache_mollom
    drop_table :cache_page if table_exists? :cache_page
    drop_table :cache_rules if table_exists? :cache_rules
    drop_table :cache_update if table_exists? :cache_update
    drop_table :cache_views if table_exists? :cache_views
    drop_table :cache_views_data if table_exists? :cache_views_data
    drop_table :captcha_points if table_exists? :captcha_points
    drop_table :captcha_sessions if table_exists? :captcha_sessions
    drop_table :comment_notify if table_exists? :comment_notify
    drop_table :comment_notify_user_settings if table_exists? :comment_notify_user_settings
    drop_table :contact if table_exists? :contact
    drop_table :content_type_blog if table_exists? :content_type_blog
    drop_table :ctools_access_ruleset if table_exists? :ctools_access_ruleset
    drop_table :ctools_css_cache if table_exists? :ctools_css_cache
    drop_table :ctools_custom_content if table_exists? :ctools_custom_content
    drop_table :ctools_object_cache if table_exists? :ctools_object_cache
    drop_table :custom_breadcrumb if table_exists? :custom_breadcrumb
    drop_table :dashboard_default if table_exists? :dashboard_default
    drop_table :dashboard_page if table_exists? :dashboard_page
    drop_table :dashboard_widget if table_exists? :dashboard_widget
    drop_table :date_format_locale if table_exists? :date_format_locale
    drop_table :date_format_types if table_exists? :date_format_types
    drop_table :date_formats if table_exists? :date_formats
    drop_table :devel_queries if table_exists? :devel_queries
    drop_table :devel_times if table_exists? :devel_times
    drop_table :event if table_exists? :event
    drop_table :event_timezones if table_exists? :event_timezones
    drop_table :feeds_imagegrabber if table_exists? :feeds_imagegrabber
    drop_table :feeds_importer if table_exists? :feeds_importer
    drop_table :feeds_node_item if table_exists? :feeds_node_item
    drop_table :feeds_push_subscriptions if table_exists? :feeds_push_subscriptions
    drop_table :feeds_source if table_exists? :feeds_source
    drop_table :feeds_term_item if table_exists? :feeds_term_item
    drop_table :filter_formats if table_exists? :filter_formats
    drop_table :filters if table_exists? :filters
    drop_table :flood if table_exists? :flood
    drop_table :freelinking if table_exists? :freelinking
    drop_table :geo if table_exists? :geo
    drop_table :history if table_exists? :history
    drop_table :imagecache_action if table_exists? :imagecache_action
    drop_table :imagecache_preset if table_exists? :imagecache_preset
    drop_table :invite if table_exists? :invite
    drop_table :invite_notifications if table_exists? :invite_notifications
    drop_table :job_schedule if table_exists? :job_schedule
    drop_table :languages if table_exists? :languages
    drop_table :locales_source if table_exists? :locales_source
    drop_table :locales_target if table_exists? :locales_target
    drop_table :mailhandler if table_exists? :mailhandler
    drop_table :menu_custom if table_exists? :menu_custom
    drop_table :menu_links if table_exists? :menu_links
    drop_table :menu_router if table_exists? :menu_router
    drop_table :messaging_message_parts if table_exists? :messaging_message_parts
    drop_table :messaging_store if table_exists? :messaging_store
    drop_table :mollom if table_exists? :mollom
    drop_table :mollom_form if table_exists? :mollom_form
    drop_table :node_comment_statistics if table_exists? :node_comment_statistics
    drop_table :node_type if table_exists? :node_type
    drop_table :notifications if table_exists? :notifications
    drop_table :notifications_event if table_exists? :notifications_event
    drop_table :notifications_fields if table_exists? :notifications_fields
    drop_table :notifications_queue if table_exists? :notifications_queue
    drop_table :notifications_sent if table_exists? :notifications_sent
    drop_table :notify if table_exists? :notify
    drop_table :openid_association if table_exists? :openid_association
    drop_table :openid_nonce if table_exists? :openid_nonce
    drop_table :openid_provider_association if table_exists? :openid_provider_association
    drop_table :openid_provider_relying_party if table_exists? :openid_provider_relying_party
    drop_table :openlayers_layers if table_exists? :openlayers_layers
    drop_table :openlayers_map_presets if table_exists? :openlayers_map_presets
    drop_table :openlayers_styles if table_exists? :openlayers_styles
    drop_table :page_manager_handlers if table_exists? :page_manager_handlers
    drop_table :page_manager_pages if table_exists? :page_manager_pages
    drop_table :page_manager_weights if table_exists? :page_manager_weights
    drop_table :permission if table_exists? :permission
    drop_table :print_node_conf if table_exists? :print_node_conf
    drop_table :print_page_counter if table_exists? :print_page_counter
    drop_table :print_pdf_node_conf if table_exists? :print_pdf_node_conf
    drop_table :print_pdf_page_counter if table_exists? :print_pdf_page_counter
    drop_table :private if table_exists? :private
    drop_table :protected_nodes if table_exists? :protected_nodes
    drop_table :role if table_exists? :role
    drop_table :rules_rules if table_exists? :rules_rules
    drop_table :rules_scheduler if table_exists? :rules_scheduler
    drop_table :rules_sets if table_exists? :rules_sets
    drop_table :search_autocomplete_forms if table_exists? :search_autocomplete_forms
    drop_table :search_autocomplete_suggestions if table_exists? :search_autocomplete_suggestions
    drop_table :search_dataset if table_exists? :search_dataset
    drop_table :search_index if table_exists? :search_index
    drop_table :search_node_links if table_exists? :search_node_links
    drop_table :search_total if table_exists? :search_total
    drop_table :semaphore if table_exists? :semaphore
    drop_table :sessions if table_exists? :sessions
    drop_table :simpleviews if table_exists? :simpleviews
    drop_table :spamicide if table_exists? :spamicide
    drop_table :stylizer if table_exists? :stylizer
    drop_table :system if table_exists? :system
    drop_table :tableofcontents_node_toc if table_exists? :tableofcontents_node_toc
    drop_table :taxonomy_manager_merge if table_exists? :taxonomy_manager_merge
    drop_table :term_hierarchy if table_exists? :term_hierarchy
    drop_table :term_relation if table_exists? :term_relation
    drop_table :term_synonym if table_exists? :term_synonym
    drop_table :to_do if table_exists? :to_do
    drop_table :to_do_assigned_users if table_exists? :to_do_assigned_users
    drop_table :to_do_block_user_preferences if table_exists? :to_do_block_user_preferences
    drop_table :token_custom if table_exists? :token_custom
    drop_table :trigger_assignments if table_exists? :trigger_assignments
    drop_table :users_roles if table_exists? :users_roles
    drop_table :variable if table_exists? :variable
    drop_table :views_display if table_exists? :views_display
    drop_table :views_object_cache if table_exists? :views_object_cache
    drop_table :views_view if table_exists? :views_view
    drop_table :vocabulary if table_exists? :vocabulary
    drop_table :vocabulary_node_types if table_exists? :vocabulary_node_types
    drop_table :watchdog if table_exists? :watchdog
    drop_table :wysiwyg if table_exists? :wysiwyg
  end

  def down
    drop_table :node_access
    drop_table :profile_fields
    drop_table :profile_values
    drop_table :uploads
    create_table "content_field_map", :id => false, :options=>'ENGINE=MyISAM' do |t|
      t.integer "vid",                                            :default => 0, :null => false
      t.integer "nid",                                            :default => 0, :null => false
      t.text    "field_map_openlayers_wkt", :limit => 2147483647
      t.integer "delta",                                          :default => 0, :null => false
    end
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

  end
end
