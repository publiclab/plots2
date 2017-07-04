class AddUserBioAndToken < ActiveRecord::Migration
  def up
    add_column :rusers, :bio, :text
    add_column :rusers, :token, :string
    add_column :rusers, :status, :integer, default: 0
    remove_column :rusers, :location_privacy

    # copy bios into new fields for non-spam users
    DrupalUsers.where('status != 0').each do |u|
      user = u.user
      user.status = u.status
      user.bio = DrupalProfileValue.find_by_uid(user.id, conditions: { fid: 7 })
      user.save({})
    end
  end

  def down
    remove_column :rusers, :bio
    remove_column :rusers, :token
    remove_column :rusers, :status
    add_column :rusers, :location_privacy, :boolean
  end
end
