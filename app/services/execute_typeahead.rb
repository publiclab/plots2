class ExecuteTypeahead
  def by(type, search_criteria, limit)
    execute(type, search_criteria, limit)
  end

  private

  def execute(type, search_criteria, limit)
    sservice = TypeaheadService.new
    sresult = TagList.new
    result = case type
      when :all
        sservice.search_all(search_criteria.query, limit)
      when :profiles
        sservice.search_profiles(search_criteria.query, limit)
      when :notes
        sservice.search_notes(search_criteria.query, limit)
      when :questions
        sservice.search_questions(search_criteria.query, limit)
      when :tags
        sservice.search_tags(search_criteria.query, limit)
      when :comments
        sservice.search_comments(search_criteria.query, limit)
      else
        []
      end
    end
end
