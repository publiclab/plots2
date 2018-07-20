class ExecuteTypeahead
  def by(type, search_criteria, limit)
    execute(type, search_criteria, limit)
  end

  private

  def execute(type, search_criteria, limit)
    sservice = TypeaheadService.new
    sresult = TagList.new
    case type
      when :all
        sresult = sservice.search_all(search_criteria.query, limit)
      when :profiles
        sresult = sservice.search_profiles(search_criteria.query, limit)
      when :notes
        sresult = sservice.search_notes(search_criteria.query, limit)
      when :questions
        sresult = sservice.search_questions(search_criteria.query, limit)
      when :tags
        sresult = sservice.search_tags(search_criteria.query, limit)
      when :comments
        sresult = sservice.search_comments(search_criteria.query, limit)
      else
        sresult = []
      end
    end
end
