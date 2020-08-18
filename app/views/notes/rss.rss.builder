xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Recent research notes on PublicLab.org"
    xml.description "Open source environmental science research at Public Lab"
    xml.link "https://#{request.host}/feed.rss"
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: "https://#{request.host}/feed.rss"

    @notes.includes(user: [:user_tags]).each do |node|
      author = node.author.username
      if node.author.has_power_tag('twitter')
        author = "@#{node.author.get_value_of_power_tag('twitter')}"
      end

      xml.item do
        xml.title      node.title + " (##{node.id})"
        xml.author     author
        xml.pubDate     node.created_at.to_s(:rfc822)
        xml.link        "https://" + request.host.to_s + node.path
        body = auto_link(body, sanitize: false)
        body = "<p><a href='https://#{request.host}/moderate/publish/#{@node.id}'>Approve</a> or <a href='https://#{request.host}/moderate/spam/<%= node.id %>'>Spam</a></p>" + body if node.status == 4
        if node.main_image
          xml.description  {  xml.cdata!("<img src='https://#{request.host}#{node.main_image.path(:default)}' alt='#{node.main_image.title}'> <br />" + body) }
        else
          xml.description  {  xml.cdata!("<img src='https://publiclab.org/system/images/photos/000/023/444/original/Screenshot_20180204-101546_2.png' alt='PublicLab'> <br />" + body) }
        end
        xml.guid url_for only_path: false, controller: 'notes', action: 'show', id: node.nid
      end
    end
  end
end
