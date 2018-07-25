# The SearchService class is a utility class whose purpose is to provide detailed responses to queries within
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the TypeaheadService, the implementation is separate, in that the goal of the response
# is to provide _detailed_ results at a deep level.  In effect, TypeaheadService provides pointers to
# better searches, while SearchService provides deep and detailed information.
#
# See SrchScope class for more details about the reusable scope
# that Search and Typeahead services use
class SearchService
  def initialize; end

  # Run a search in any of the associated systems for references that contain the search string
  # and package up as a DocResult
  def textSearch_all(srchString)
    sresult = DocList.new

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

    sresult
  end

  # Search profiles for matching text and package up as a DocResult
  # If order == "recentdesc", search for more recently updated profiles for matching text.
  # Otherwise, show profiles without any ordering
  def textSearch_profiles(srchString, order = nil)
    sresult = DocList.new

    users =
      if order == "recentdesc"
        getRecentProfiles(srchString)
      else
        SrchScope.find_users(srchString, limit = nil)
      end

    # User profiles
    users.each do |match|
      doc = DocResult.fromSearch(0, 'user', '/profile/' + match.name, match.name, '', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search notes for matching strings and package up as a DocResult
  def textSearch_notes(srchString)
    sresult = DocList.new

    notes = SrchScope.find_notes(srchString, 25)
    notes.each do |match|
      doc = DocResult.fromSearch(match.nid, 'file', match.path, match.title, match.body.split(/#+.+\n+/, 5)[1], 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search maps for matching text and package up as a DocResult
  def textSearch_maps(srchString)
    sresult = DocList.new

    maps = SrchScope.find_maps(srchString, 5)

    maps.select('title,type,nid,path').each do |match|
      doc = DocResult.fromSearch(match.nid, match.icon, match.path, match.title, '', 0)
      sresult.addDoc(doc)
    end

    sresult
  end

  # Search documents with matching tag values and package up as a DocResult
  # The search string that is passed in is split into tokens, and the tag names are compared and
  # chained to the notes that are tagged with those values
  def textSearch_tags(srchString)
    sresult = DocList.new

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

    sresult
  end

  # Search question entries for matching text and package up as a DocResult
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

  # Search nearby nodes with respect to given latitude, longitute and tags
  # and package up as a DocResult
  def tagNearbyNodes(srchString, tagName)
    sresult = DocList.new

    lat, lon =  srchString.split(',')

    nodes_scope = NodeTag.joins(:tag)
      .where('name LIKE ?', 'lat:' + lat[0..lat.length - 2] + '%')

    if tagName.present?
      nodes_scope = NodeTag.joins(:tag)
                           .where('name LIKE ?', tagName)
                           .where(nid: nodes_scope.select(:nid))
    end

    nids = nodes_scope.collect(&:nid).uniq || []

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

  # GET X number of latest people/contributors and package up as a DocResult
  # X = srchString
  def recentPeople(srchString, tagName = nil)
    sresult = DocList.new
    users = getRecentProfilesTag(tagName)
    count = 0

    users.each do |user|
      next unless user.has_power_tag("lat") && user.has_power_tag("lon")
      blurred = false
      if user.has_power_tag("location")
        blurred = user.get_value_of_power_tag("location")
      end
      doc = DocResult.fromLocationSearch(user.id, 'people_coordinates', user.path, user.username, 0, 0, user.lat, user.lon, blurred)
      sresult.addDoc(doc)
      count += 1
      if count == srchString.to_i then break end
    end

    sresult
  end

  # Get users with matching name ordering by most recent activity
  def getRecentProfiles(srchString)
    sresult = DocList.new

    nodes = Node.all.order("changed DESC").limit(100).distinct
    users = []
    nodes.each do |node|
      next unless (node.author.status != 0) and (node.author.name.downcase.include? srchString.downcase)
      users << node.author.user
    end

    users = users.uniq
  end

  # If a tagName is provided,
  # method returns users with the specific tag ordering by most recent activity.
  # Otherwise, it returns users with most recent activity.
  def getRecentProfilesTag(tagName = nil)
    nodes = Node.all.order("changed DESC").limit(100).distinct
    users = []
    nodes.each do |node|
      if node.author.status != 0
        if tagName.blank?
          users << node.author.user
        else
          users << node.author.user if node.author.user.has_tag(tagName)
        end
      end
    end

    users = users.uniq
  end
end
