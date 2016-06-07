class SearchService

  def initialize
  end

  def users(params)
    @users ||= find_users(params)
  end

  def tags(params)
    @tags ||= find_tags(params)
  end

  def notes(params)
    @notes ||= find_notes(params)
  end

  def maps(params)
    @maps ||= find_maps(params)
  end

  def find_users(input)
    DrupalUsers.limit(5)
        .order('uid DESC')
        .where('name LIKE ? AND access != 0', '%' + input + '%')
  end

  def find_tags(input)
    DrupalTag.includes(:drupal_node)
        .where('node.status = 1')
        .limit(5)
        .where('name LIKE ?', '%' + input + '%')
  end

  ## search for node title only
  ## FIXme with solr
  def find_notes(input)
    DrupalNode.limit(5)
        .order('nid DESC')
        .where('type = "note" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  def find_maps(input)
    DrupalNode.limit(5)
        .order('nid DESC')
        .where('type = "map" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  def type_ahead(id)
    matches = []

    notes(id).select("title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='fa fa-file'></i> "+match.title
    end

    DrupalNode.limit(5)
        .order("nid DESC")
        .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', "%" + id + "%")
        .select("title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='fa fa-"+match.icon+"'></i> "+match.title
    end

    maps(id).select("title,type,nid,path").each do |match|
      matches << "<i data-url='"+match.path+"' class='fa fa-"+match.icon+"'></i> "+match.title
    end

    users(id).each do |match|
      matches << "<i data-url='/profile/"+match.name+"' class='fa fa-user'></i> "+match.name
    end

    tags(id).each do |match|
      matches << "<i data-url='/tag/"+match.name+"' class='fa fa-tag'></i> "+match.name
    end

    return matches
  end

end
