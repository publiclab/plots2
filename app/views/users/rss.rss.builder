xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Research by "+params[:author]
    xml.description "Open source environmental science research at Public Lab"
    xml.link "/feed/"+params[:author]

   @notes.each do |node|

     body = node.body
     body = "<img src='"+node.main_image.path(:default)+"'/><br /> "+node.body if node.main_image

     xml.item do
       xml.title       node.title
       xml.author      node.author.name
       xml.pubDate     node.created_at.to_s(:rfc822)
       xml.link        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
       #xml.image "http://publiclaboratory.org/"+node.main_image.path(:default) if node.main_image
       xml.description body 
       xml.guid        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
     end
   end
  end
end
