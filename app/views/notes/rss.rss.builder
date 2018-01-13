xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Recent research notes on PublicLab.org"
    xml.description "Open source environmental science research at Public Lab"
    xml.link "https://#{ request.host }/feed.rss"

   @notes.each do |node|

     body = node.latest.render_body
     body = "<p><![CDATA[ <img src='"+node.main_images.path(:default)+"' alt='"+node.main_image.title+"' > ]]></p> " + node.body if node.main_image

     xml.item do
       xml.title       node.title
       xml.author      node.author.user.has_power_tag('twitter') ? "@" + node.author.user.get_value_of_power_tag('twitter') : node.author.username
       xml.pubDate     node.created_at.to_s(:rfc822)
       #xml.link        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
       xml.link        "https://" + request.host.to_s + node.path
       xml.description auto_link(body, :sanitize => false)
       xml.guid        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
     end
   end
  end
end
