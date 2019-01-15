class DropDrupalProfileValueAndField < ActiveRecord::Migration[5.1]
  def up
    if table_exists? "drupal_profile_values"
      drop_table :drupal_profile_values
    end
    if table_exists? "drupal_profile_fields"
      drop_table :drupal_profile_fields
    end
  end

  def down
  end
end
