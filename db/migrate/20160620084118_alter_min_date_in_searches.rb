class AlterMinDateInSearches < ActiveRecord::Migration
  def change
    change_column :searches, :min_date,  :string
  end
end
