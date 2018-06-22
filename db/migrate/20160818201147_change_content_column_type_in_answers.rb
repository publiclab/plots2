class ChangeContentColumnTypeInAnswers < ActiveRecord::Migration[5.1]
  def up
    change_column :answers, :content, :text, limit: 2147483647
  end

  def down
    change_column :answers, :content, :string
  end
end
