class TaggifyMapCoords < ActiveRecord::Migration
  def up
    @maps = DrupalNode.find(:all, :conditions => {:type => 'map', :status => 1})
    @maps.each do |map|
      unless map.has_power_tag("lon")
        map.add_tag("lon:"+map.location[:x].to_s,map.author)
        map.add_tag("lat:"+map.location[:y].to_s,map.author)
      end
    end
  end

  def down
  end
end
