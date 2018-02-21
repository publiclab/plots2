class AddDateRageToSearches < ActiveRecord::Migration
  def change
    rename_column :searches, :date_created, :max_date
    add_column :searches, :min_date, :integer
  end
end
