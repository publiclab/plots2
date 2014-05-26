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
      drupaltags = DrupalTag.count(:all)
      summ += "\nTags:              "+drupaltags.to_s
      drupalnodetags = DrupalNodeTag.count(:all)
      summ += "\nNodeTags:          "+drupalnodetags.to_s
      drupalnodecommunitytags = DrupalNodeCommunityTag.count(:all)
      summ += "\nCommunityNodeTags: "+drupalnodecommunitytags.to_s
      summ += "\n========================================"
      tags = DrupalTag.find(:all,:select => [:name])
      utags = tags.uniq.length
      summ += "\nDuplicate tags:    "+(tags.length-utags).to_s
      summ += "\n========================================"
      puts summ
   
      # remove spaces
      DrupalTag.find(:all).each do |tag|
        tag.name = tag.name.downcase.gsub(' ','-')
        tag.save
      end

      # delete all orphaned node_tags
      deleted = []
      ntags = DrupalNodeTag.find(:all)
      puts "node_tags:"
      puts ntags.length
      ntags.each do |nt|
        if nt.tag.nil? || nt.node.nil? || nt.node.status == 0
          deleted << nt.tag.name 
          nt.delete
        end
      end
      puts "deleted invalids:"
      puts deleted.join(',')
 
      # convert all DrupalNodeTag into DrupalNodeCommunityTag with uid = 0
      failed = []
      deleted = []
      dupes = 0
      ntags = DrupalNodeTag.find(:all)
      puts "node_tags for active pages:"
      puts ntags.length
      ntags.each do |ntag|
        ctag = DrupalNodeCommunityTag.new({
          :uid => 0, # oh well. Someone can inherit these someday if need be.
          :tid => ntag.tid,
          :date => DateTime.now.to_i, # we never saved these before, so we don't know; just use current time
          :nid => ntag.nid
        })
        if DrupalNodeCommunityTag.find_all_by_nid(ntag.nid, :conditions => {:tid => ntag.tid}).length > 0
          dupes += 1
        elsif ctag.save
          deleted << ntag.tag.name unless ntag.tag.nil?
          ntag.delete 
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
 
      # get rid of DrupalTag duplicates, ensure no new dupes are created
      failed = []
      dupes = 0
      uniqtags = DrupalTag.find(:all).collect(&:name).uniq
      uniqtags.each do |uniqtag|
        origtag = DrupalTag.find_by_name uniqtag, :order => "tid"
        DrupalTag.find_all_by_name(uniqtag).each do |tag_clone|
          # re-assign all TagSelections to newly consolidated DrupalTag tids
          TagSelection.find_all_by_tid(tag_clone.tid).each do |tsel|
            # ensure unique
            unless TagSelection.find(:first, :conditions => {:tid => origtag.tid, :user_id => tsel.user_id})
              tsel.tid = origtag.tid
              tsel.save
            end
          end
          # re-assign node_tag to the first instance of tag
          DrupalNodeCommunityTag.find_all_by_tid(tag_clone.tid).each do |ctag|
            ctag.tid = origtag.tid
            if DrupalNodeCommunityTag.find_all_by_nid(ctag.nid, :conditions => {:tid => ctag.tid}).length > 0
              ctag.delete
              dupes += 1
            elsif !ctag.save
              failed << ctag
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
      DrupalTag.find(:all).each do |tag|
        # delete orphans
        if tag.drupal_node_tag.length == 0 && tag.drupal_node_community_tag.length == 0 && tag.subscriptions.length == 0
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
      drupaltags2 = DrupalTag.count(:all)
      summ += "\nTags:              "+drupaltags2.to_s
      drupalnodetags2 = DrupalNodeTag.count(:all)
      summ += "\nNodeTags:          "+drupalnodetags2.to_s
      drupalnodecommunitytags2 = DrupalNodeCommunityTag.count(:all)
      summ += "\nCommunityNodeTags: "+drupalnodecommunitytags2.to_s
      summ += "\n========================================"
      summ += "\nFewer Tags:             "+(drupaltags-drupaltags2).to_s
      summ += "\nFewer NodeTags:         "+(drupalnodetags-drupalnodetags2).to_s
      summ += "\nMore CommunityNodeTags: "+(drupalnodecommunitytags2-drupalnodecommunitytags).to_s
      summ += "\n========================================"
      tags = DrupalTag.find(:all,:select => [:name])
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
