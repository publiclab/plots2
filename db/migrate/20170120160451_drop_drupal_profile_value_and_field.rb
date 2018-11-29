class DropDrupalProfileValueAndField < ActiveRecord::Migration[5.1]
  def up
    if table_exists? "drupal_profile_value"
      drop_table :drupal_profile_value
    end
    if table_exists? "drupal_profile_field"
      drop_table :drupal_profile_field
    end
  end

  def down
  end
end
