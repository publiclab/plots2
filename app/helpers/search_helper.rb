module SearchHelper
  def create_nav_links(active_page, query)
    links = [
      { section: "search-all", text: "All Content", path: "/search/#{query}" },
      { section: "search-notes", text: "Notes", path: "/search/notes/#{query}" },
      { section: "search-wikis", text: "Wikis", path: "/search/wikis/#{query}/" },
      { section: "search-profiles", text: "Profiles", path: "/search/profiles/#{query}/" },
      { section: "search-tags", text: "Tags", path: "/search/tags/#{query}/" },
      { section: "search-questions", text: "Questions", path: "/search/questions/#{query}/" },
      { section: "search-places", text: "Places", path: "/search/places/#{query}/" }
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
end
