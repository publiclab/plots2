class ExecuteSearch
  def by(type, search_criteria)
    execute(type, search_criteria)
  end

  private

  def execute(type, search_criteria)
    sservice = SearchService.new
    sresult = DocList.new
    case type
     when :all
       sresult = sservice.textSearch_all(search_criteria)
     when :profiles
       sresult = sservice.textSearch_profiles(search_criteria)
     when :notes
       sresult = sservice.textSearch_notes(search_criteria.query)
     when :questions
       sresult = sservice.textSearch_questions(search_criteria.query)
     when :tags
       sresult = sservice.textSearch_tags(search_criteria.query)
     when :peoplelocations
       sresult = sservice.recentPeople(search_criteria.query, search_criteria.tag)
     when :taglocations
       if search_criteria.query.include? ","
         sresult = sservice.tagNearbyNodes(search_criteria.query, search_criteria.tag)
       end
     else
       sresult = []
     end
  end
end
