class AddUserBioAndToken < ActiveRecord::Migration
  def up
    add_column :rusers, :bio, :text, limit: 2147483647
    add_column :rusers, :token, :string
    add_column :rusers, :status, :integer, default: 0
    remove_column :rusers, :location_privacy

    # copy bios into new fields for non-spam users
    DrupalUsers.where('status != 0').each do |u|
      unless u.name.multibyte? # exclude non-latin names
        user = u.user
        if user and defined? :u.status then
          user.status = u.status
          user.bio = DrupalProfileValue.find_by_uid(user.id, conditions: { fid: 7 }) || ''
          user.token = SecureRandom.uuid
          user.save({})
        end
      end
    end
    drop_table :location_tags
    drop_table :searches
  end

  def down
    remove_column :rusers, :bio
    remove_column :rusers, :token
    remove_column :rusers, :status
    add_column :rusers, :location_privacy, :boolean
  end
end
