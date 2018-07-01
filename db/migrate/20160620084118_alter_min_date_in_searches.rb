class AlterMinDateInSearches < ActiveRecord::Migration[5.1]
  def change
    change_column :searches, :min_date,  :string
  end
end
