module SolrToggle

  def shouldIndexSolr
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
