xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Research tagged '#{params[:tagname]}' by #{params[:authorname]}"
    xml.description "Open source environmental science research at Public Lab"
    xml.link "https://#{request.host}/feed/tag/"+params[:tagname]+"/author/"+"params[:authorname]"+".rss"

    @notes.each do |node|

      body = node.body
      uname = node.author.username
       email = node.author.email
       if node.author.user.has_power_tag('twitter')
         uname = node.author.user.get_value_of_power_tag('twitter')
       end
       author_format = "@#{uname} (#{email})"
       xml.item do
       xml.title      " #{node.title}"
       xml.author     author_format
       if node.power_tag('date') != ''
          begin
            xml.pubDate     DateTime.strptime(node.power_tag('date'), "%m-%d-%Y").rfc822
          rescue
            xml.pubDate     node.power_tag('date')
          end
        else
          xml.pubDate     node.created_at.to_s(:rfc822)
        end
        xml.link        "https://" + request.host.to_s + node.path
        if node.main_image
          xml.description  {  xml.cdata!("<img src='#{node.main_image.path(:default)}' alt='#{node.main_image.title}'>")  }
        else
          xml.description  {  xml.cdata!("<img src='https://i.publiclab.org/system/images/photos/000/000/354/medium/Boots-ground-02.png' alt='PublicLab'><p>#{body}</p>")  }
        end
        xml.guid        url_for :only_path => false, :controller => 'notes', :action => 'show', :id => node.nid
      end
    end
  end
end
