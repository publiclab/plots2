# The TypeaheadService class is a utility class whose purpose is to provide fast responses to text queries within
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the SearchService, the implementation is separate, in that the goal of the response
# is to provide _fast_ returns at a higher level than a general search.  In effect, TypeaheadService provides pointers to
# better searches, while SearchService provides deep and detailed information.
# TODO: Refactor TypeaheadService and SearchService so that common functions come from a higher level class?
class TypeaheadService
  def initialize; end

  # search_users() returns a standard TagResult; 
  # users() returns an array of User records
  # It's unclear if TagResult was supposed to be broken into other types like DocResult?
  # but perhaps could simply be renamed Result.

  def users(input, limit = 5)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      User.search(input)
        .limit(limit)
        .where(status: 1)
    else 
      User.limit(limit)
        .order('id DESC')
        .where('username LIKE ? AND status = 1', '%' + input + '%')
    end
  end

  def tags(input, limit = 5)
    Tag.includes(:node)
      .references(:node)
      .where('node.status = 1')
      .limit(limit)
      .where('name LIKE ?', '%' + input + '%')
      .group('node.nid')
  end

  def comments(input, limit = 5)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      Comment.search(input)
        .limit(limit)
        .order('nid DESC')
        .where(status: 1)
    else 
      Comment.limit(limit)
        .order('nid DESC')
        .where('status = 1 AND comment LIKE ?', '%' + input + '%')
    end
  end

  def notes(input, limit = 5)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      Node.search(input)
        .group(:nid)
        .includes(:node)
        .references(:node)
        .limit(limit)
        .where("node.type": "note", "node.status": 1)
        .order('node.changed DESC')
    else 
      Node.limit(limit)
        .group(:nid)
        .where(type: "note", status: 1)
        .order(changed: :desc)
        .where('title LIKE ?', '%' + input + '%')
    end
  end

  def wikis(input, limit = 5)
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      Node.search(input)
        .group('node.nid')
        .includes(:node)
        .references(:node)
        .limit(limit)
        .where("node.type": "page", "node.status": 1)
    else 
      Node.limit(limit)
        .order('nid DESC')
        .where('type = "page" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
    end
  end

  def maps(input, limit = 5)
    Node.limit(limit)
      .order('nid DESC')
      .where('type = "map" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
  end

  # Run a search in any of the associated systems for references that contain the search string
  def search_all(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # notes
      notesrch = search_notes(srchString, limit)
      sresult.addAll(notesrch.getTags)
      # wikis
      wikisrch = search_wikis(srchString, limit)
      sresult.addAll(wikisrch.getTags)
      # User profiles
      usersrch = search_profiles(srchString, limit)
      sresult.addAll(usersrch.getTags)
      # Tags -- handled differently because tag
      tagsrch = search_tags(srchString, limit)
      sresult.addAll(tagsrch.getTags)
      # maps
      mapsrch = search_maps(srchString, limit)
      sresult.addAll(mapsrch.getTags)
      # questions
      qsrch = search_questions(srchString, limit)
      sresult.addAll(qsrch.getTags)
      #comments
      commentsrch = search_comments(srchString, limit)
      sresult.addAll(commentsrch.getTags)
    end
    sresult
  end

  # Search profiles for matching text
  def search_profiles(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # User profiles
      users(srchString, limit).each do |match|
        tval = TagResult.new
        tval.tagId = 0
        tval.tagType = 'user'
        tval.tagVal = match.username
        tval.tagSource = '/profile/' + match.username
        sresult.addTag(tval)
      end
    end
    sresult
  end

  # Search notes for matching strings
  def search_notes(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      notes(srchString, limit).uniq.each do |match|
        tval = TagResult.new
        tval.tagId = match.nid
        tval.tagVal = match.title
        tval.tagType = 'file'
        tval.tagSource = match.path
        sresult.addTag(tval)
      end
    end
    sresult
  end

  # Search wikis for matching strings
  def search_wikis(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      wikis(srchString, limit).select('node.title,node.type,node.nid,node.path').each do |match|
        tval = TagResult.new
        tval.tagId = match.nid
        tval.tagVal = match.title
        tval.tagType = 'file'
        tval.tagSource = match.path
        sresult.addTag(tval)
      end
    end
    sresult
  end

  # Search maps for matching text
  def search_maps(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # maps
      maps(srchString, limit).select('title,type,nid,path').each do |match|
        tval = TagResult.new
        tval.tagId = match.nid
        tval.tagVal = match.title
        tval.tagType = match.icon
        tval.tagSource = match.path
        sresult.addTag(tval)
      end
    end
    sresult
  end

  # Search tag values for matching text
  def search_tags(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # Tags
      tlist = tags(srchString, limit)
      tlist.each do |match|
        ntag = TagResult.new
        ntag.tagId = 0
        ntag.tagVal = match.name
        ntag.tagType = 'tag'
        sresult.addTag(ntag)
      end
    end
    sresult
  end

  # Search question entries for matching text
  def search_questions(input, limit = 5)
    sresult = TagList.new
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      questions = Node.search(input)
        .group(:nid)
        .includes(:node)
        .references(:node)
        .limit(limit)
        .where("node.type": "note", "node.status": 1)
        .order('node.changed DESC')
        .joins(:tag)
        .where('term_data.name LIKE ?', 'question:%')
    else 
      questions = Node.where('title LIKE ?', '%' + input + '%')
        .joins(:tag)
        .where('term_data.name LIKE ?', 'question:%')
        .limit(limit)
        .group(:nid)
        .where(type: "note", status: 1)
        .order(changed: :desc)
    end
    questions.each do |match|
      tval = TagResult.fromSearch(
        match.nid,
        match.title,
        'question-circle',
        match.path
      )
      sresult.addTag(tval)
    end
    sresult
  end

  # Search comments for matching text
  def search_comments(srchString, limit = 5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      comments(srchString, limit).each do |match|
        tval = TagResult.new
        tval.tagId = match.pid
        tval.tagVal = match.comment.truncate(20)
        tval.tagType = 'comment'
        tval.tagSource = match.parent.path
        sresult.addTag(tval)
      end
    end
    sresult
  end

end
