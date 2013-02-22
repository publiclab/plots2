xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Research by "+params[:author]
    xml.description "Open source environmental science research at Public Lab"
    xml.link "/feed/"+params[:author]

   @notes.each do |node|

     xml.item do
       xml.title       node.title
       xml.author      node.author.name
       xml.pubDate     node.created_at.to_s(:rfc822)
       xml.link        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
       #xml.image "http://spectralworkbench.org"+spectrum.photo.url(:large)
       xml.description node.body
       xml.guid        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
     end
   end
  end
end
