class AddLatestActivityNidToTag < ActiveRecord::Migration[5.2]
  def change
    add_column :term_data, :latest_activity_nid, :string
  end
end
