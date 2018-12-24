class AddFieldsToNode < ActiveRecord::Migration[5.2]
  def up
    add_column :node, :latitude, :decimal, :precision => 20, :scale => 17
    add_column :node, :longitude, :decimal, :precision => 20, :scale => 17
    add_column :node, :precision, :integer

    sql = "SELECT `node`.`nid`,`term_data`.`name` FROM `node` LEFT OUTER JOIN `community_tags` ON `community_tags`.`nid` = `node`.`nid` LEFT OUTER JOIN `term_data` ON `term_data`.`tid` = `community_tags`.`tid` WHERE (term_data.name LIKE 'lat:%' or term_data.name LIKE 'lon:%')"
    tags_array = ActiveRecord::Base.connection.exec_query(sql)
    tags_array.each do |tag|
      node_id = tag["nid"]
      if tag["name"].include? 'lon:'
        long = tag["name"].gsub("lon:","").to_f
        update "UPDATE `node` SET `precision` = '" + decimals(long).to_s + "' WHERE nid = '" + node_id.to_s + "'"
        update "UPDATE `node` SET `longitude` = '" + long.to_s + "' WHERE nid = '" + node_id.to_s + "'"
      else
        lati = tag["name"].gsub("lat:","")
        update "UPDATE `node` SET `latitude` = '" + lati + "' WHERE nid = '" + node_id.to_s + "'"
      end
    end
  end

  def down
    remove_column :node, :latitude
    remove_column :node, :longitude
    remove_column :node, :precision
  end

  def decimals(n)
    if not n.to_s.include? '.'
      return 0
    else
      return n.to_s.split('.').last.size
    end
  end
end
