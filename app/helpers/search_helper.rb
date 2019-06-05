module SearchHelper
  def create_nav_links(active_page, query)
    links = [
      { section: "search-all", text: "Content", path: "/search/#{query}" },
      { section: "search-profiles", text: "People", path: "/search/profiles/#{query}/" }
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
