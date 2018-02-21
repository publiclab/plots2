class AddLanguageToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :language, :string
  end
end
