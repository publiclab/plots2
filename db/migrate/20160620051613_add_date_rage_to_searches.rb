class AddDateRageToSearches < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :date_created, :max_date
    add_column :searches, :min_date, :integer
  end
end
