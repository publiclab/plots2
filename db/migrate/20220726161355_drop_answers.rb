class DropAnswers < ActiveRecord::Migration[5.2]
  def change
    drop_table :answers
  end
end
