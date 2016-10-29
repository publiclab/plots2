# The TypeaheadService class is a utility class whose purpose is to provide fast responses to text queries within 
# different categories (record types, functionality, subsystems, etc).
# Though similar in operation to the SearchService, the implementation is separate, in that the goal of the response
# is to provide _fast_ returns at a higher level than a general search.  In effect, TypeaheadService provides pointers to 
# better searches, while SearchService provides deep and detailed information.
# TODO: Refactor TypeaheadService and SearchService so that common functions come from a higher level class?
class TypeaheadService

  def initialize
  end

  def users(params, limit)
    @users ||= find_users(params, limit)
  end

  def tags(params, limit)
    @tags ||= find_tags(params,limit)
  end

  def notes(params, limit)
    @notes ||= find_notes(params)
  end

  def maps(params, limit)
    @maps ||= find_maps(params, limit)
  end

  def comments(params, limit)
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


  # Run a search in any of the associated systems for references that contain the search string
  def textSearch_all(srchString, limit=5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # notes
      notesrch = textSearch_notes(srchString, limit)
      sresult.addAll(notesrch.getTags)
      # User profiles
      usersrch = textSearch_profiles(srchString, limit)
      sresult.addAll(usersrch.getTags)
      # Tags -- handled differently because tag
      tagsrch = textSearch_tags(srchString, limit)
      sresult.addAll(tagsrch.getTags)
      # maps
      mapsrch = textSearch_maps(srchString, limit)
      sresult.addAll(mapsrch.getTags)
      # questions
      qsrch = textSearch_questions(srchString, limit)
      sresult.addAll(qsrch.getTags)
    end
    return sresult
  end

  # Search profiles for matching text
  def textSearch_profiles(srchString, limit=5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # User profiles
      users(srchString,limit).each do |match|
        tval = TagResult.new
        tval.tagId = 0
        tval.tagType = "user"
        tval.tagVal = match.name
        sresult.addTag(tval)
      end
    end
    return sresult
  end  

  # Search notes for matching strings
  def textSearch_notes(srchString, limit=5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # notes
      notes(srchString,limit).select("title,type,nid").each do |match|
        tval = TagResult.new
        tval.tagId = match.nid
        tval.tagVal = match.title
        tval.tagType = "file"
        sresult.addTag(tval)
      end
    end
    return sresult
  end  

  # Search maps for matching text
  def textSearch_maps(srchString, limit=5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # maps
      maps(srchString, limit).select("title,type,nid").each do |match|
        tval = TagResult.new
        tval.tagId = match.nid
        tval.tagVal = match.title
        tval.tagType = match.icon
        sresult.addTag(tval)
      end
    end
    return sresult
  end

  # Search tag values for matching text
  def textSearch_tags(srchString, limit=5)
    sresult = TagList.new
    unless srchString.nil? || srchString == 0
      # Tags
       tlist= DrupalTag.includes(:drupal_node)
        .where('node.status = 1')
        .limit(limit)
        .where('name LIKE ?', '%' + srchString + '%')
      tlist.each do |match|
        ntag = TagResult.new
        ntag.tagId = 0
        ntag.tagVal = match.name
        ntag.tagType = "tag"
        sresult.addTag(ntag)
      end
    end
    return sresult
  end

  # Search question entries for matching text
  def textSearch_questions(srchString, limit=5)
    sresult = TagList.new
    questions = DrupalNode.where(
                  'type = "note" AND node.status = 1 AND title LIKE ?',
                  "%" + srchString + "%"
                )
                  .joins(:drupal_tag)
                  .where('term_data.name LIKE ?', 'question:%')
                  .order('node.nid DESC')
                  .limit(limit)
    questions.each do |match|
      tval = TagResult.fromSearch(
               match.nid,
               match.title,
               "question-circle",
               match.path
      )
      sresult.addTag(tval)
    end
    return sresult
  end

end
