class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.integer :uid
      t.string :value

      t.timestamps
    end
  end
end
