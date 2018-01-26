xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Research tagged '#{params[:tagname]}'"
    xml.description "Open source environmental science research at Public Lab"
    xml.link "https://#{request.host}/feed/tag/"+params[:tagname]+".rss"

    @notes.each do |node|
    
      body = node.body
      body = "<img src='"+node.main_image.path(:default)+"'/><br /> "+node.body if node.main_image
    
      xml.item do
        xml.title       node.title
        xml.author      node.author.name
        if node.power_tag('date') != ''
          begin
            xml.pubDate     DateTime.strptime(node.power_tag('date'), "%m-%d-%Y").rfc822
          rescue
            xml.pubDate     node.power_tag('date')
          end
        else
          xml.pubDate     node.created_at.to_s(:rfc822)
        end
        #xml.link        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
        xml.link        "https://" + request.host.to_s + node.path
        #xml.image "//#{ request.host }/"+node.main_image.path(:default) if node.main_image
        xml.description auto_link(node.latest.render_body, :sanitize => false)
        xml.guid        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
      end
    end
  end
end
