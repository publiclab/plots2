
class ChangeCommentsToUtf8mb4 < ActiveRecord::Migration[5.2]
  def change
    config   = Rails.configuration.database_configuration
    execute "ALTER DATABASE " + config[Rails.env]["database"] + " CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"
    # changing table that will store unicode execute:
    execute "ALTER TABLE comments ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE comments CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    # changing string/text column with unicode content execute:
    execute "ALTER TABLE comments MODIFY comment longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE comments MODIFY name varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE comments MODIFY homepage varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE node ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE node CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE node MODIFY title varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE node MODIFY path varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE node MODIFY slug varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE csvfiles ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE csvfiles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE csvfiles MODIFY filetitle varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE csvfiles MODIFY filedescription text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE csvfiles MODIFY filepath text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE csvfiles MODIFY filename varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE csvfiles MODIFY filestring text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE images ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE images CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE images MODIFY title varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE images MODIFY notes varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE images MODIFY photo_file_name varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE images MODIFY photo_content_type varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE images MODIFY photo_file_size varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE node_revisions ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE node_revisions CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE node_revisions MODIFY title varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE node_revisions MODIFY body longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE node_revisions MODIFY teaser text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE node_revisions MODIFY log text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE term_data ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE term_data CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE term_data MODIFY name varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE term_data MODIFY parent varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE term_data MODIFY description longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE rusers ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE rusers CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE rusers MODIFY username title varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY email varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY crypted_password varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY password_salt varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY persistence_token varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY photo_file_name varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY csvfile varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE rusers MODIFY bio longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE user_tags ROW_FORMAT=DYNAMIC"
    execute "ALTER TABLE user_tags CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE user_tags MODIFY data text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE user_tags MODIFY value varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
