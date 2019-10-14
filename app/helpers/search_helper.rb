module SearchHelper
  def create_nav_links(active_page, query)
    links = nav_links(query)
    base_class = "list-group-item list-group-item-action"
    result = links.map do |link|
      active_link = (active_page == link[:section] ? "#{base_class} active" : base_class)
      "<li><a href='#{link[:path]}' class='#{active_link}'>#{link[:text]}</a> </li>"
    end
    result.join(" ").html_safe
  end

  def create_nav_links_for_by_type(active_page, query)
    links = nav_links_for_by_type(query)
    base_class = "dropdown-item"
    result = links.map do |link|
      active_link = (active_page == link[:section] ? "#{base_class} active" : base_class)
      "<a href='#{link[:path]}' class='#{active_link}'>#{link[:text]}</a>"
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
end
