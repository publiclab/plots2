class ExecuteSearch
  def by(type, search_criteria)
    execute(type, search_criteria)
  end

  private

  def execute(type, search_criteria)
    sservice = SearchService.new
    case type
     when :all
       sservice.search_all(search_criteria)
     when :profiles
       sservice.search_profiles(search_criteria)
     when :notes
       sservice.search_notes(search_criteria.query, search_criteria.limit)
     when :wikis
       sservice.search_wikis(search_criteria.query, search_criteria.limit)
     when :questions
       sservice.search_questions(search_criteria.query, search_criteria.limit, search_criteria.sort_by)
     when :tags
       sservice.search_tags(search_criteria.query, search_criteria.limit)
     when :taglocations
       sservice.tagNearbyNodes(search_criteria.coordinates, search_criteria.tag, search_criteria.period, search_criteria.sort_by, search_criteria.order_direction, search_criteria.limit)
     when :nearbyPeople
       sservice.tagNearbyPeople(search_criteria.coordinates, search_criteria.tag, search_criteria.field, search_criteria.period, search_criteria.sort_by, search_criteria.order_direction, search_criteria.limit)
     else
       []
     end
  end
end
