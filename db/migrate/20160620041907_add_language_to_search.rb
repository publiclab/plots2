class AddLanguageToSearch < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :language, :string
  end
end
