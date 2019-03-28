class CreateRusers < ActiveRecord::Migration[5.1]
  def self.up
    unless table_exists? "rusers"
      create_table :rusers do |t|
        t.string :username
        t.string :email
  #      t.string :password

        t.string    :crypted_password,    :null => true
        t.string    :password_salt,       :null => true
        t.string    :persistence_token,   :null => false
        #t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
        #t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

        # magic fields (all optional, see Authlogic::Session::MagicColumns)
        t.integer   :login_count,         :null => false, :default => 0
        t.integer   :failed_login_count,  :null => false, :default => 0
        t.datetime  :last_request_at
        t.datetime  :current_login_at
        t.datetime  :last_login_at
        t.string    :current_login_ip
        t.string    :last_login_ip

        t.timestamps
      end
    end
  end

  def self.down
    drop_table :rusers
  end
end
