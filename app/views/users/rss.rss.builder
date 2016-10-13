xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Research by "+params[:author]
    xml.description "Open source environmental science research at Public Lab"
    xml.link "https://#{ Rails.root }/feed/"+params[:author]+".rss"

   @notes.each do |node|

    newline = '&#13;&#10;'

     body = node.body
     body = "<img src='"+node.main_image.path(:default)+"'/><br />"+newline+node.body if node.main_image

     xml.item do
       xml.title       node.title
       xml.author      node.author.name
       xml.pubDate     node.created_at.to_s(:rfc822)
       #xml.link        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
       xml.link        "https://" + Rails.root.to_s + node.path
       #xml.image "http://publiclaboratory.org/"+node.main_image.path(:default) if node.main_image
       xml.description auto_link(node.latest.render_body, :sanitize => false)
       xml.guid        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
     end
   end
  end
end
