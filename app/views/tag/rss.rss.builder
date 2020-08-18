xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Research tagged '#{params[:tagname]}'"
    xml.description "Open source environmental science research at Public Lab"
    xml.link "https://#{request.host}/feed/tag/" + params[:tagname] + ".rss"
    xml.rel "self"

    @notes.includes(user: [:user_tags]).each do |node|
      body = node.body
      author = node.author.username
      if node.author.has_power_tag('twitter')
        author = "@#{node.author.get_value_of_power_tag('twitter')}"
      end
      xml.item do
        xml.title      node.title
        xml.author     author
        if node.power_tag('date') != ''
          begin
            xml.pubDate     (DateTime.strptime(node.power_tag('date'), "%m-%d-%Y").in_time_zone("GMT") + 5.hours).rfc822
          rescue StandardError
            xml.pubDate     node.power_tag('date')
          end
        else
          xml.pubDate node.created_at.to_s(:rfc822)
         end
        xml.link "https://" + request.host.to_s + node.path
        if node.main_image
          xml.description  {  xml.cdata!("<img src='https://#{request.host}#{node.main_image.path(:default)}' alt='#{node.main_image.title}'> <p>#{auto_link(node.latest.render_body, sanitize: false)}</p>") }
        else
          xml.description  {  xml.cdata!("<img src='https://publiclab.org/system/images/photos/000/023/444/original/Screenshot_20180204-101546_2.png' alt='PublicLab'><p>#{auto_link(node.latest.render_body, sanitize: false)}</p>") }
        end
        xml.guid url_for only_path: false, controller: 'notes', action: 'show', id: node.nid
      end
    end
  end
end
