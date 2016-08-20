class ChangeContentColumnTypeInAnswers < ActiveRecord::Migration
  def up
    change_column :answers, :content, :text, limit: 2147483647
  end

  def down
    change_column :answers, :content, :string
  end
end
