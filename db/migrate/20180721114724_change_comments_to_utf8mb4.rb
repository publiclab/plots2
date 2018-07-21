class ChangeCommentsToUtf8mb4 < ActiveRecord::Migration[5.2]
   def change
    # changing table that will store unicode execute:
    execute "ALTER TABLE comments CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    # changin string/text column with unicode content execute:
    execute "ALTER TABLE comments MODIFY comment VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
