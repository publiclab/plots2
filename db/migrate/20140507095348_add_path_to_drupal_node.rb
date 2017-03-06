class AddPathToDrupalNode < ActiveRecord::Migration
  def up
    add_column :node, :path, :string
    Node.reset_column_information

    # used to first delete url_alias records that do not correspond to any node
    # or are replaced by a route + controller
    @first_filter = ActiveRecord::Base.connection.execute('select pid, src, dst from url_alias where src not like "users/%" and src not like "people/%" and src not like "user/%" and src not like "taxonomy/%" and src not like "blog/%" and src not like "%/feed" and src not like "%/add%";')
    puts "Size after first filter: #{@first_filter.size}"
    puts "Should be #{Node.count}"

    puts "Quick break to set up Node redirects:"
    # url_a[1] is the node id in the form of 'node/123'
    # url_a[2] is the actual url
    duplicate_node_ids = (@first_filter.to_a - @first_filter.to_a.uniq { |url_a| url_a[1] })
    cleaned_node_ids = duplicate_node_ids.uniq { |url_a| url_a[2] }
    puts "There were #{cleaned_node_ids.size} duplicate node ids in url_alias"
    cleaned_node_ids.each do |redirect_node|
      path = redirect_node[2]
      Node.transaction do
        ActiveRecord::Base.connection.execute(
          "insert into node (title, type, path) values('REDIRECT-#{redirect_node[2]}-#{Random.rand}', 'redirect|#{redirect_node[1].split('/').last}', '/#{path}');")
        tmp_node = Node.last
        ActiveRecord::Base.connection.execute(
          "insert into node_revisions (nid, uid) values(#{tmp_node.nid}, 1);")
        ActiveRecord::Base.connection.execute(
          "update node set vid = #{DrupalNodeRevision.last.vid} where nid = #{tmp_node.nid};")
      end
    end

    second_filter = @first_filter.to_a.uniq { |item| item[1] }

    third_filter = []
    second_filter.each do |item|
      node_id = item[1].match(/\d+/)
      if !node_id.nil? && Node.where(nid: node_id[0]).first != []
        third_filter << item + [node_id[0]]
      end
    end


    fourth_filter = []
    third_filter.each do |item|
      if Node.where(nid: item.last.to_i) != []
        fourth_filter << item
      end
    end


    if fourth_filter.size > 0
      ActiveRecord::Base.connection.execute("delete from url_alias where pid not in (#{fourth_filter.map { |i| i[0].to_i }.join(',')});")
      no_of_aliases = ActiveRecord::Base.connection.execute('select count(pid) from url_alias;')
      puts no_of_aliases.to_a
    end

    dsts = ActiveRecord::Base.connection.execute('select dst, src from url_alias;')
    dsts.each do |dst, src|
      node = Node.where(:nid => src.split('/').last).first
      if node
        node.path = "/#{dst}"
        if node.valid?
          node.save
        else
          node.path = "DUPLICATE-#{Random.rand}"
          node.save
        end
      end
    end
    


    drop_table :url_alias
  end
    

  def down
    remove_column :node, :path

    create_table :url_alias, :primary_key => "pid" do |t|
      t.string :src, :limit => 128, default: "", :null => false
      t.string :dst, :limit => 128, default: "", :null => false
      t.string :language, :limit => 12, :default => "", :null => false
    end
  end
end
