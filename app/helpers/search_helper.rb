module SearchHelper
  def create_nav_links(active_page, query)
    links = [
      { section: "search-all", text: "Content", path: "/search/#{query}" },
      { section: "search-profiles", text: "People", path: "/search/profiles/#{query}" }
    ]

    result = ""
    links.each do |link|
      active_link =
        if active_page == link[:section]
          "list-group-item list-group-item-action active"
        else
          "list-group-item list-group-item-action"
        end
      result += " <li><a href='#{link[:path]}' class='#{active_link}'>#{link[:text]}</a> </li>"
    end
    result.html_safe
  end

  def create_nav_links_for_by_type(active_page, query)
    links = [
      { section: "search-all", text: "All content types", path: "/search/content/#{query}" },
      { section: "search-questions", text: "Questions", path: "/search/questions/#{query}" },
      { section: "search-notes", text: "Notes", path: "/search/notes/#{query}" },
      { section: "search-wikis", text: "Wikis", path: "/search/wikis/#{query}" },
      { section: "search-tags", text: "Tags", path: "/search/tags/#{query}" }
    ]

    result = ""
    links.each do |link|
      active_link =
        if active_page == link[:section]
          "dropdown-item active"
        else
          "dropdown-item"
        end
      result += " <a href='#{link[:path]}' class='#{active_link}'>#{link[:text]}</a>"
    end
    result.html_safe
  end
end
