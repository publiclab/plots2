class AddTagCount < ActiveRecord::Migration[5.1]
  def up
    add_column :term_data, :count, :integer
    Tag.all.each do |tag|
      tag.run_count
    end
  end

  def down
    remove_column :term_data, :count
  end
end
