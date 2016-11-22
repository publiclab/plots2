class RemoveFriendlyIdIndices < ActiveRecord::Migration
  def up
    remove_index :friendly_id_slugs, :sluggable_id
    remove_index :friendly_id_slugs, [:slug, :sluggable_type]
    remove_index :friendly_id_slugs, :sluggable_type
  end

  def down
  end
end
