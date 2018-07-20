# The TypeaheadService class is a utility class whose purpose is to provide fast responses to text queries within
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the SearchService, the implementation is separate, in that the goal of the response
# is to provide _fast_ returns at a higher level than a general search.  In effect, TypeaheadService provides pointers to
# better searches, while SearchService provides deep and detailed information.
#
# See SrchScope class for more details about the reusable scope
# that Typeahead and Search services use
class TypeaheadService
  def initialize; end

  def tags(input, limit = 5)
    SrchScope.find_tags(input, limit)
             .group('node.nid')
  end

  # default order is recency
  def nodes(input, _limit = 5, order = :default)
    Node.search(query: input, order: order, limit: 5)
      .group(:nid)
      .where('node.status': 1)
  end

  def notes(input, limit = 5, order = :default)
    nodes(input, limit, order)
      .where("node.type": "note")
  end

  def maps(input, limit = 5, order = :default)
    nodes(input, limit, order)
      .where("node.type": "map")
  end

  # Run a search in any of the associated systems for references that contain the search string
  # and package up as a TagResult
  def search_all(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      # notes
      notesrch = search_notes(search_string, limit)
      sresult.addAll(notesrch.getTags)
      # wikis
      wikisrch = search_wikis(search_string, limit)
      sresult.addAll(wikisrch.getTags)
      # User profiles
      usersrch = search_profiles(search_string, limit)
      sresult.addAll(usersrch.getTags)
      # Tags -- handled differently because tag
      tagsrch = search_tags(search_string, limit)
      sresult.addAll(tagsrch.getTags)
      # maps
      mapsrch = search_maps(search_string, limit)
      sresult.addAll(mapsrch.getTags)
      # questions
      qsrch = search_questions(search_string, limit)
      sresult.addAll(qsrch.getTags)
      # comments
      commentsrch = search_comments(search_string, limit)
      sresult.addAll(commentsrch.getTags)
    end
    sresult
  end

  # Search profiles for matching text and package up as a TagResult
  def search_profiles(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      users = SrchScope.find_users(search_string, limit)
      users.each do |match|
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

  # Search notes for matching strings and package up as a TagResult
  def search_notes(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      notes = notes(search_string, limit).distinct
      notes.each do |match|
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

  # Search wikis for matching strings and package up as a TagResult
  def search_wikis(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      wikis = SrchScope.find_wikis(search_string, limit, order = :default)
      wikis.select('node.title,node.type,node.nid,node.path').each do |match|
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

  # Search maps for matching text and package up as a TagResult
  def search_maps(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      # maps
      maps(search_string, limit).select('title,type,nid,path').each do |match|
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

  # Search tag values for matching text and package up as a TagResult
  def search_tags(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      # Tags
      tlist = tags(search_string, limit)
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

  # Search question entries for matching text and package up as a TagResult
  def search_questions(input, limit = 5)
    sresult = TagList.new
    questions = SrchScope.find_questions(input, limit, order = :default)
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

  # Search comments for matching text and package up as a TagResult
  def search_comments(search_string, limit = 5)
    sresult = TagList.new
    unless search_string.nil? || search_string.blank?
      comments = SrchScope.find_comments(search_string, limit)
      comments.each do |match|
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
