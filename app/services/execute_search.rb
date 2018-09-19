class ExecuteSearch
  def by(type, search_criteria)
    execute(type, search_criteria)
  end

  private

  def execute(type, search_criteria)
    sservice = SearchService.new
    case type
     when :all
       return sservice.search_all(search_criteria)
     when :profiles
       return sservice.search_profiles(search_criteria)
     when :notes
       return sservice.search_notes(search_criteria.query, search_criteria.limit)
     when :questions
       return sservice.search_questions(search_criteria.query, search_criteria.limit)
     when :tags
       return sservice.search_tags(search_criteria.query, search_criteria.limit)
     when :peoplelocations
       return sservice.people_locations(search_criteria.query, search_criteria.tag)
     when :taglocations
       return sservice.tagNearbyNodes(search_criteria.query, search_criteria.tag)
     else
       sresult = []
     end
  end
end
