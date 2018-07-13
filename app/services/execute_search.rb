class ExecuteSearch
  def by(type, search_criteria)
    execute(type, search_criteria)
  end

  private

  def execute(type, search_criteria)
    sservice = SearchService.new
    case type
      when :all
        return sservice.textSearch_all(search_criteria.query)
      when :profiles
        return sservice.textSearch_profiles(search_criteria.query)
      when :notes
        return sservice.textSearch_notes(search_criteria.query)
      when :questions
        return sservice.textSearch_questions(search_criteria.query)
      when :tags
        return sservice.textSearch_tags(search_criteria.query)
      when :peoplelocations
        return sservice.recentPeople(search_criteria.query, search_criteria.tag)
      when :taglocations
        if search_criteria.query.include? ","
          return sservice.tagNearbyNodes(search_criteria.query, search_criteria.tag)
        end
      else
        return []
      end
    end
end
