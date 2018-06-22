class AddSearchfieldsToSearches < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :main_type, :string
    add_column :searches, :note_type, :string
    add_column :searches, :created_by, :string
    add_column :searches, :date_created, :string
  end
end
