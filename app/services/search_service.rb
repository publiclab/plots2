class SearchService

  def initialize
  end

  def type_ahead(id)
    matches = []

    DrupalNode.limit(5)
        .order("nid DESC")
        .where('type = "note" AND node.status = 1 AND title LIKE ?', "%" + id + "%")
        .select("title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='fa fa-file'></i> "+match.title
    end
    DrupalNode.limit(5)
        .order("nid DESC")
        .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', "%" + id + "%")
        .select("title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='fa fa-"+match.icon+"'></i> "+match.title
    end
    DrupalNode.limit(5)
        .order("nid DESC")
        .where('type = "map" AND node.status = 1 AND title LIKE ?', "%" + id + "%")
        .select("title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='fa fa-"+match.icon+"'></i> "+match.title
    end
    DrupalUsers.limit(5)
        .order("uid DESC")
        .where('name LIKE ? AND access != 0', "%" + id + "%").each do |match|
      matches << "<i data-url='/profile/"+match.name+"' class='fa fa-user'></i> "+match.name
    end
    DrupalTag.includes(:drupal_node)
        .where('node.status = 1')
        .limit(5)
        .where('name LIKE ?', "%" + id + "%").each do |match|
      matches << "<i data-url='/tag/"+match.name+"' class='fa fa-tag'></i> "+match.name
    end
    return matches
  end


end
