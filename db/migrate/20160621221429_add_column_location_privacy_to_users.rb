class AddColumnLocationPrivacyToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :rusers, :location_privacy, :boolean, default: true
    add_index :rusers, :location_privacy
  end

  def down
    remove_index :rusers, :location_privacy
    remove_column :rusers, :location_privacy
  end
end
