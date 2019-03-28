if ActiveRecord::Base.connection.adapter_name == "Mysql2"
  begin
    require 'active_record/connection_adapters/mysql2_adapter'

    class ActiveRecord::ConnectionAdapters::Mysql2Adapter
      NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
    end
  rescue Exception => e
    raise
    e.message
  end
end
