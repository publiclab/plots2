module SolrToggle

  def solr_available?
    if ENV["DISABLE_SOLR"]
      false
    else
      begin
        if !Sunspot::Rails.configuration.disabled?
          Node.search do
            fulltext 'test' # provisional, shouldn't matter?
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

end
