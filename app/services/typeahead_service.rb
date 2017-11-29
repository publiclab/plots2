# The TypeaheadService class is a utility class whose purpose is to provide fast responses to text queries within
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the SearchService, the implementation is separate, in that the goal of the response
# is to provide _fast_ returns at a higher level than a general search.  In effect, TypeaheadService provides pointers to
# better searches, while SearchService provides deep and detailed information.
# TODO: Refactor TypeaheadService and SearchService so that common functions come from a higher level class?
class TypeaheadService
  def initialize; end
  include SolrToggle

  # search_users() returns a standard TagResult; 
  # users() returns an array of User records
  # It's unclear if TagResult was supposed to be broken into other types like DocResult?
  # but perhaps could simply be renamed Result.

  def users(input, limit = 5)
    User.limit(limit)
        .order('id DESC')
        .where('username LIKE ? AND status = 1', '%' + input + '%')
  end

  def tags(input, limit = 5)
    Tag.includes(:node)
       .references(:node)
       .where('node.status = 1')
       .limit(limit)
       .where('name LIKE ?', '%' + input + '%')
  end

  def comments(input, limit = 5)
    Comment.limit(limit)
           .order('nid DESC')
           .where('status = 1 AND comment LIKE ?', '%' + input + '%')
  end

  def notes(input, limit = 5)
    if solrAvailable
      search = Node.search do
        fulltext input
        with :status, 1
        #with :type, "note"
        order_by :updated_at, :desc
        paginate page: 1, per_page: limit
      end
      search.results
    else 
      Node.limit(limit)
          .order('nid DESC')
          .where(type: "note", status: 1)
          .where('title LIKE ?', '%' + input + '%')
    end
  end

  def wikis(input, limit = 5)
    Node.limit(limit)
        .order('nid DESC')
        .where('type = "page" AND node.status = 1 AND title LIKE ?', '%' + input + '%')
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
      notes(srchString, limit).each do |match|
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
      wikis(srchString, limit).select('title,type,nid,path').each do |match|
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
  def search_questions(srchString, limit = 5)
    sresult = TagList.new
    questions = Node.where(
      'type = "note" AND node.status = 1 AND title LIKE ?',
      '%' + srchString + '%'
    )
                    .joins(:tag)
                    .where('term_data.name LIKE ?', 'question:%')
                    .order('node.nid DESC')
                    .limit(limit)
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
end
