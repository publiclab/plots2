class AddTagCount < ActiveRecord::Migration
  def up
    add_column :term_data, :count, :integer
    DrupalTag.all.each do |tag|
      tag.run_count
    end
  end

  def down
    remove_column :term_data, :count
  end
end
