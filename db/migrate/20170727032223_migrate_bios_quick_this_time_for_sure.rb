class MigrateBiosQuickThisTimeForSure < ActiveRecord::Migration
  def up
    execute "UPDATE rusers,profile_values SET rusers.bio=profile_values.value WHERE rusers.id=profile_values.uid AND rusers.status!=0"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
