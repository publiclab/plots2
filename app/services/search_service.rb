# The SearchService class is a utility class whose purpose is to provide detailed responses to queries within 
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the TypeaheadService, the implementation is separate, in that the goal of the response
# is to provide _detailed_ results at a deep level.  In effect, TypeaheadService provides pointers to 
# better searches, while SearchService provides deep and detailed information.
# TODO: Refactor TypeaheadService and SearchService so that common functions come from a higher level class?
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

  def comments
    @comments ||= find_comments(params)
  end

  def find_users(input, limit=5)
    DrupalUsers.limit(limit)
        .order('uid DESC')
        .where('name LIKE ? AND access != 0', '%' + input + '%')
  end

  def find_tags(input, limit=5)
    DrupalTag.includes(:drupal_node)
        .where('node.status = 1')
        .limit(limit)
        .where('name LIKE ?', '%' + input + '%')
  end

  def find_comments(input, limit=5)
    DrupalComment.limit(limit)
        .order('nid DESC')
        .where('status = 1 AND comment LIKE ?', '%' + input + '%')
  end

  ## search for node title only
  ## FIXme with solr
  def find_notes(input, limit=5)
    DrupalNode.limit(limit)
        .order('nid DESC')
        .where('type = "note" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  def find_maps(input, limit=5)
    DrupalNode.limit(limit)
        .order('nid DESC')
        .where('type = "map" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end
  
  # DEPRECATED
  def type_ahead(id)
    warn "[DEPRECATED] SearchService.type_ahead is deprecated.  Use the TypeaheadService methods instead."
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

  # Run a search in any of the associated systems for references that contain the search string
  def textSearch_all(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # notes
      noteList = textSearch_notes(srchString)
      sresult.addAll(noteList.items)
      
      # DrupalNode search
      DrupalNode.limit(5)
      .order("nid DESC")
      .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', "%" + srchString + "%")
      .select("title,type,nid,path").each do |match|
        doc = DocResult.fromSearch(match.nid,match.icon,match.path,match.title,"",0)
        sresult.addDoc(doc)
      end
      # User profiles
      userList = textSearch_profiles(srchString)
      sresult.addAll(userList.items)
      
      # Tags
      tagList = textSearch_tags(srchString)
      sresult.addAll(tagList.items)
      # maps
      mapList = textSearch_maps(srchString)
      sresult.addAll(mapList.items)
      # questions
      qList = textSearch_questions(srchString)
      sresult.addAll(qList.items)
    end
    return sresult
  end

  # Search profiles for matching text
  def textSearch_profiles(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # User profiles
      users(srchString).each do |match|
        doc = DocResult.fromSearch(0,"user","/profile/"+match.name,match.name,"",0)
        sresult.addDoc(doc)
      end
    end
    return sresult
  end  

  # Search notes for matching strings
  def textSearch_notes(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # notes
      find_notes(srchString,25).each do |match|
        doc = DocResult.fromSearch(match.nid,"file",match.path,match.title,match.body.split(/#+.+\n+/,5)[1],0)
        sresult.addDoc(doc)
      end
    end
    return sresult
  end  

  # Search maps for matching text
  def textSearch_maps(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # maps
      maps(srchString).select("title,type,nid,path").each do |match|
        doc = DocResult.fromSearch(match.nid,match.icon,match.path,match.title,"",0)
        sresult.addDoc(doc)
      end
    end
    return sresult
  end

  # Search documents with matching tag values
  # The search string that is passed in is split into tokens, and the tag names are compared and
  # chained to the notes that are tagged with those values
  def textSearch_tags(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # Tags
      sterms = srchString.split(" ")
      tlist= DrupalTag.where({ name: sterms })
        .joins(:drupal_node_community_tag)
        .joins(:drupal_node)
        .where('node.status = 1')
        .select('DISTINCT node.nid,node.title,node.path')
      tlist.each do |match|
        tagdoc = DocResult.fromSearch(match.nid,"tag",match.path,match.title,"",0)
        sresult.addDoc(tagdoc)
      end
    end
    return sresult
  end

  # Search question entries for matching text
  def textSearch_questions(srchString)
    sresult = DocList.new
    questions = DrupalNode.where(
                  'type = "note" AND node.status = 1 AND title LIKE ?',
                  "%" + srchString + "%"
                )
                  .joins(:drupal_tag)
                  .where('term_data.name LIKE ?', 'question:%')
                  .order('node.nid DESC')
                  .limit(25)
    questions.each do |match|
      doc = DocResult.fromSearch(match.nid,'question-circle',match.path(:question),match.title,0,match.answers.length.to_i)
      sresult.addDoc(doc)
    end
    return sresult
  end

end
