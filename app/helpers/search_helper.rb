module SearchHelper
  def create_nav_links(active_page, query) 
    base_class = "list-group-item list-group-item-action"
    result = nav_links(query).map do |link|
      "<li><a href='#{link[:path]}' class='#{generate_class(active_page, base_class, link[:section])}'>#{link[:text]}</a> </li>"
    end
    result.join(" ").html_safe
  end

  def create_nav_links_for_by_type(active_page, query)
    base_class = "dropdown-item"
    result = nav_links_for_by_type(query).map do |link|
      "<a href='#{link[:path]}' class='#{generate_class(active_page, base_class, link[:section])}'>#{link[:text]}</a>"
    end
    result.join(" ").html_safe
  end

  private

  def nav_links_for_by_type(query)
    [
      { section: "search-all", text: "All content types", path: "/search/content/#{query}" },
      { section: "search-questions", text: "Questions", path: "/search/questions/#{query}" },
      { section: "search-notes", text: "Notes", path: "/search/notes/#{query}" },
      { section: "search-wikis", text: "Wikis", path: "/search/wikis/#{query}" }
    ]
  end

  def nav_links(query)
    [
      { section: "search-all", text: "Content", path: "/search/#{query}" },
      { section: "search-profiles", text: "People", path: "/search/profiles/#{query}" }
    ]
  end

  def generate_class(active_page, base_class, section)
    (active_page == section ? "#{base_class} active" : base_class)
  end
end
