module SolrToggle

  def shouldIndexSolr
    if ENV["DISABLE_SOLR_CHECK"]
      true
    else
      solrAvailable
    end
  end

  def solrAvailable
    begin
      if !Sunspot::Rails.configuration.disabled?
        Node.search do
          fulltext 'test' # just see if we break things
        end
        true
      else
        false
      end
    rescue
      false
    end
  end

end
