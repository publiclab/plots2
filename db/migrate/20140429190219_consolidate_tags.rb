class ConsolidateTags < ActiveRecord::Migration
  def up

    # before wrapping the rest in a transaction, we have to make sure the database supports transactions
    execute "ALTER TABLE comments ENGINE = InnoDB"
    execute "ALTER TABLE community_tags ENGINE = InnoDB"
    execute "ALTER TABLE content_field_bbox ENGINE = InnoDB"
    execute "ALTER TABLE content_field_image_gallery ENGINE = InnoDB"
    execute "ALTER TABLE content_field_main_image ENGINE = InnoDB"
    execute "ALTER TABLE content_field_map_editor ENGINE = InnoDB"
    execute "ALTER TABLE content_field_mappers ENGINE = InnoDB"
    execute "ALTER TABLE content_type_map ENGINE = InnoDB"
    execute "ALTER TABLE files ENGINE = InnoDB"
    execute "ALTER TABLE node ENGINE = InnoDB"
    execute "ALTER TABLE node_access ENGINE = InnoDB"
    execute "ALTER TABLE node_counter ENGINE = InnoDB"
    execute "ALTER TABLE node_revisions ENGINE = InnoDB"
    execute "ALTER TABLE profile_fields ENGINE = InnoDB"
    execute "ALTER TABLE profile_values ENGINE = InnoDB"
    execute "ALTER TABLE term_data ENGINE = InnoDB"
    execute "ALTER TABLE term_node ENGINE = InnoDB"
    execute "ALTER TABLE upload ENGINE = InnoDB"
    execute "ALTER TABLE url_alias ENGINE = InnoDB"
    execute "ALTER TABLE users ENGINE = InnoDB"

    ActiveRecord::Base.transaction do

      # do some tallies to check success:
      summ =  "\n======= BEGIN TAG CONSOLIDATION ========"
      drupaltags = Tag.count(:all)
      summ += "\nTags:              "+drupaltags.to_s
      drupalnodetags = ActiveRecord::Base.connection.execute('select COUNT(*) from term_node;')
      summ += "\nNodeTags:          "+drupalnodetags.first[0].to_s
      drupalnodecommunitytags = DrupalNodeCommunityTag.count(:all)
      summ += "\nCommunityNodeTags: "+drupalnodecommunitytags.to_s
      summ += "\n========================================"
      tags = Tag.find(:all,:select => [:name])
      utags = tags.uniq.length
      summ += "\nDuplicate tags:    "+(tags.length-utags).to_s
      summ += "\n========================================"
      puts summ
   
      # remove spaces
      Tag.find(:all).each do |tag|
        tag.name = tag.name.downcase.gsub(' ','-')
        tag.save
      end

      # delete all orphaned node_tags
      deleted = []
      ntags = ActiveRecord::Base.connection.execute('select * from term_node;')
      puts "node_tags:"
      puts ntags.size
      ntags.each do |nt|
        node1 = Node.find(nt[0])
        if nt[2].nil? || nt[0].nil? || (node1 && node1.status == 0)
          # nt - [nid, vid, tid]
          tag = Tag.find(nt[2])
          deleted << tag.name 
          ActiveRecord::Base.connection.execute("delete from term_node where vid = #{nt[1]};")
        end
      end
      puts "deleted invalids:"
      puts deleted.join(',')
 
      # convert all DrupalNodeTag into DrupalNodeCommunityTag with uid = 0
      failed = []
      deleted = []
      dupes = 0
      ntags = ActiveRecord::Base.connection.execute('select * from term_node;')
      puts "node_tags for active pages:"
      puts ntags.size
      ntags.each do |ntag|
        ctag = DrupalNodeCommunityTag.new({
          :uid => 0, # oh well. Someone can inherit these someday if need be.
          :tid => ntag[2],
          :date => DateTime.now.to_i, # we never saved these before, so we don't know; just use current time
          :nid => ntag[0]
        })
        if DrupalNodeCommunityTag.find_all_by_nid(ntag[0], :conditions => {:tid => ntag[2]}).length > 0
          dupes += 1
        elsif ctag.save
          tag = Tag.find(ntag[2])
          deleted << tag.name unless tag.nil?
          ActiveRecord::Base.connection.execute("delete from term_node where vid = #{ntag[1]};")
        else
          failed << ctag
        end
      end
      puts "failed:"
      puts failed.length
          puts "tags:"
          puts failed.collect(&:tag).collect(&:name).join(',')
      puts "dupes:"
      puts dupes
      puts "deleted after migrating:"
      puts deleted.join(',')
 
      # get rid of Tag duplicates, ensure no new dupes are created
      failed = []
      dupes = 0
      uniqtags = Tag.find(:all).collect(&:name).uniq
      uniqtags.each do |uniqtag|
        # find the version with the earliest tid
        origtag = Tag.find_by_name uniqtag, :order => "tid"
        Tag.find_all_by_name(uniqtag).each do |tag_clone|
          # re-assign all TagSelections to newly consolidated Tag tids
          TagSelection.find_all_by_tid(tag_clone.tid).each do |tsel|
            # ensure unique
            unless TagSelection.find(:first, :conditions => {:tid => origtag.tid, :user_id => tsel.user_id})
              tsel.tid = origtag.tid
              tsel.save
            end
          end
          # re-assign node_tag to the first instance of tag
          DrupalNodeCommunityTag.find_all_by_tid(tag_clone.tid).each do |ctag|
            if ctag.tid != origtag.tid
              ctag.tid = origtag.tid
              if DrupalNodeCommunityTag.find_all_by_nid(ctag.nid, :conditions => {:tid => ctag.tid}).length > 0
                ctag.delete
                dupes += 1
              elsif !ctag.save
                failed << ctag
              end
            end
          end
          # re-assign tag_selection to the first instance of tag
          TagSelection.find_all_by_tid(tag_clone.tid).each do |tsel|
            # ensure unique
            unless TagSelection.find(:first, :conditions => {:tid => origtag.tid, :user_id => tsel.user_id})
              tsel.tid = origtag.tid
              tsel.save
            end
          end
        end
      end
      puts "failed:"
      puts failed.length
          puts "tags:"
          puts failed.collect(&:name).join(',')
      puts "dupes:"
      puts dupes

      # now find all orphaned tags and delete them: 
      deleted = []
      Tag.find(:all).each do |tag|
        # delete orphans
        related_drupal_node_tags = ActiveRecord::Base.connection.execute("select * from term_node where tid = #{tag.id};")
        if related_drupal_node_tags.size == 0 && tag.drupal_node_community_tag.length == 0 && tag.subscriptions.length == 0
          deleted << tag.name
          tag.delete 
        end
      end
      puts "deleted orphans:"
      puts deleted.join(',')

      # do some final tallies to check success:
      # repeat prev. stats:
      puts summ
      # new stats:
      summ =  "\n=======  END TAG CONSOLIDATION  ========"
      drupaltags2 = Tag.count(:all)
      summ += "\nTags:              "+drupaltags2.to_s
      drupalnodetags2 = ActiveRecord::Base.connection.execute('select COUNT(*) from term_node;')
      summ += "\nNodeTags:          "+drupalnodetags2.first[0].to_s
      drupalnodecommunitytags2 = DrupalNodeCommunityTag.count(:all)
      summ += "\nCommunityNodeTags: "+drupalnodecommunitytags2.to_s
      summ += "\n========================================"
      summ += "\nFewer Tags:             "+(drupaltags-drupaltags2).to_s
      summ += "\nFewer NodeTags:         "+(drupalnodetags.first[0]-drupalnodetags2.first[0]).to_s
      summ += "\nMore CommunityNodeTags: "+(drupalnodecommunitytags2-drupalnodecommunitytags).to_s
      summ += "\n========================================"
      tags = Tag.find(:all,:select => [:name])
      utags = tags.uniq.length
      summ += "\nDuplicate tags:    "+(tags.length-utags).to_s
      summ += "\n========================================"
      puts summ
    end

  end

  # there is no undo
  def down
  end
end
