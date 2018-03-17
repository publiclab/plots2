# The SearchService class is a utility class whose purpose is to provide detailed responses to queries within
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the TypeaheadService, the implementation is separate, in that the goal of the response
# is to provide _detailed_ results at a deep level.  In effect, TypeaheadService provides pointers to
# better searches, while SearchService provides deep and detailed information.
# TODO: Refactor TypeaheadService and SearchService so that common functions come from a higher level class?

class SearchService
  def initialize; end

  def users(params)
    @users ||= find_users(params)
  end

  def tags(params)
    @tags ||= find_tags(params)
  end

  def nodes(params)
    @nodes ||= find_nodes(params)
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

  def find_users(input, limit = 10)
    User.limit(limit)
      .order('id DESC')
      .where(status: 1)
      .where('username LIKE ?', '%' + input + '%')
  end

  def find_tags(input, limit = 5)
    Tag.includes(:node)
      .references(:node)
      .where('node.status = 1')
      .limit(limit)
      .where('name LIKE ?', '%' + input + '%')
  end

  def find_comments(input, limit = 5)
    Comment.limit(limit)
      .order('nid DESC')
      .where('status = 1 AND comment LIKE ?', '%' + input + '%')
  end

  def find_nodes(input, limit = 5)
    Node.limit(limit)
      .order('nid DESC')
      .where('node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  ## search for node title only
  ## FIXme with solr
  def find_notes(input, limit = 5)
    Node.limit(limit)
      .order('nid DESC')
      .where('type = "note" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  def find_maps(input, limit = 5)
    Node.limit(limit)
      .order('nid DESC')
      .where('type = "map" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  # Run a search in any of the associated systems for references that contain the search string
  def textSearch_all(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # notes
      noteList = textSearch_notes(srchString)
      sresult.addAll(noteList.items)

      # Node search
      Node.limit(5)
        .order('nid DESC')
        .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', '%' + srchString + '%')
        .select('title,type,nid,path').each do |match|
        doc = DocResult.fromSearch(match.nid, match.icon, match.path, match.title, '', 0)
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
    sresult
  end

  # Search profiles for matching text
  def textSearch_profiles(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # User profiles
      users(srchString).each do |match|
        doc = DocResult.fromSearch(0, 'user', '/profile/' + match.name, match.name, '', 0)
        sresult.addDoc(doc)
      end
    end
    sresult
  end

  # Search notes for matching strings
  def textSearch_notes(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # notes
      find_notes(srchString, 25).each do |match|
        doc = DocResult.fromSearch(match.nid, 'file', match.path, match.title, match.body.split(/#+.+\n+/, 5)[1], 0)
        sresult.addDoc(doc)
      end
    end
    sresult
  end

  # Search maps for matching text
  def textSearch_maps(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # maps
      maps(srchString).select('title,type,nid,path').each do |match|
        doc = DocResult.fromSearch(match.nid, match.icon, match.path, match.title, '', 0)
        sresult.addDoc(doc)
      end
    end
    sresult
  end

  # Search documents with matching tag values
  # The search string that is passed in is split into tokens, and the tag names are compared and
  # chained to the notes that are tagged with those values
  def textSearch_tags(srchString)
    sresult = DocList.new
    unless srchString.nil? || srchString == 0
      # Tags
      sterms = srchString.split(' ')
      tlist = Tag.where(name: sterms)
        .joins(:node_tag)
        .joins(:node)
        .where('node.status = 1')
        .select('DISTINCT node.nid,node.title,node.path')
      tlist.each do |match|
        tagdoc = DocResult.fromSearch(match.nid, 'tag', match.path, match.title, '', 0)
        sresult.addDoc(tagdoc)
      end
    end
    sresult
  end

  # Search question entries for matching text
  def textSearch_questions(srchString)
    sresult = DocList.new
    questions = Node.where(
      'type = "note" AND node.status = 1 AND title LIKE ?',
      '%' + srchString + '%'
    )
      .joins(:tag)
      .where('term_data.name LIKE ?', 'question:%')
      .order('node.nid DESC')
      .limit(25)
    questions.each do |match|
      doc = DocResult.fromSearch(match.nid, 'question-circle', match.path(:question), match.title, 0, match.answers.length.to_i)
      sresult.addDoc(doc)
    end
    sresult
  end

  # Search nearby nodes with respect to given latitude and longitude
  def nearbyNodes(srchString)
    sresult = DocList.new
    coordinates = srchString.split(",")
    lat = coordinates[0]
    lon = coordinates[1]

    nids = NodeTag.joins(:tag)
      .where('name LIKE ?', 'lat:' + lat[0..lat.length - 2] + '%')
      .collect(&:nid)

    nids ||= []

    items = Node.includes(:tag)
      .references(:node, :term_data)
      .where('node.nid IN (?) AND term_data.name LIKE ?', nids, 'lon:' + lon[0..lon.length - 2] + '%')
      .limit(200)
      .order('node.nid DESC')

    items.each do |match|
      blurred = false

      match.node_tags.each do |tag|
        if tag.name == "location:blurred"
          blurred = true
          break
        end
      end

      doc = DocResult.fromLocationSearch(match.nid, 'coordinates', match.path(:items), match.title, 0, match.answers.length.to_i, match.lat, match.lon, blurred)
      sresult.addDoc(doc)
    end
    sresult
  end

#GET X number of latest people/contributors 
# X = srchString
def recentPeople(srchString)
    sresult = DocList.new  
    nodes = Node.all.order("changed DESC").limit(100).uniq
    users = []
    nodes.each do |node|
      users << node.author.user
    end
    users = users.uniq 
    users.each do |user|
      if user.has_power_tag("lat") && user.has_power_tag("lon") 
          blurred = false 
          if user.has_power_tag("location")
            blurred = user.get_value_of_power_tag("location")
          end
          doc = DocResult.fromLocationSearch(user.id, 'people_coordinates', user.path , user.username , 0 , 0 , user.lat , user.lon , blurred)
          sresult.addDoc(doc)
      end
    end                  
    sresult
  end

end
