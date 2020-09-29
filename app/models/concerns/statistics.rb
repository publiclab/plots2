module Statistics
  extend ActiveSupport::Concern

  def weekly_note_tally(span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Node.select(:created)
        .where(uid: uid,
               type: 'note',
               status: 1,
               created: Time.now.to_i - week.weeks.to_i..Time.now.to_i - (week - 1).weeks.to_i)
        .size
    end
    weeks
  end

  def daily_note_tally(span = 365)
    days = {}
    (1..span).each do |day|
      time = Time.now.utc.beginning_of_day.to_i
      days[(time - day.days.to_i)] = Node.select(:created)
        .where(uid: uid,
               type: 'note',
               status: 1,
               created: time - (day - 1).days.to_i..time - (day - 2).days.to_i)
        .size
    end
    days
  end

  def weekly_comment_tally(span = 52)
    weeks = {}
    (0..span).each do |week|
      weeks[span - week] = Comment.select(:timestamp)
        .where(uid: uid,
               status: 1,
               timestamp: Time.now.to_i - week.weeks.to_i..Time.now.to_i - (week - 1).weeks.to_i)
        .size
    end
    weeks
  end

  def note_streak(span = 365)
    days = {}
    streak = 0
    note_count = 0
    (0..span).each do |day|
      days[day] = Node.select(:created)
        .where(uid: id,
               type: 'note',
               status: 1,
               created: Time.now.midnight.to_i - day.days.to_i..Time.now.midnight.to_i - (day - 1).days.to_i)
        .size
      break if days[day] == 0

      streak += 1
      note_count += days[day]
    end
    [streak, note_count]
  end

  def wiki_edit_streak(span = 365)
    days = {}
    streak = 0
    wiki_edit_count = 0
    (0..span).each do |day|
      days[day] = Revision.joins(:node)
        .where(uid: uid,
               status: 1,
               timestamp: Time.now.midnight.to_i - day.days.to_i..Time.now.midnight.to_i - (day - 1).days.to_i)
        .where('node.type != ?', 'note')
        .size
      break if days[day] == 0

      streak += 1
      wiki_edit_count += days[day]
    end
    [streak, wiki_edit_count]
  end

  def comment_streak(span = 365)
    days = {}
    streak = 0
    comment_count = 0
    (0..span).each do |day|
      days[day] = Comment.select(:timestamp)
        .where(uid: uid,
          status: 1,
          timestamp: Time.now.midnight.to_i - day.days.to_i..Time.now.midnight.to_i - (day - 1).days.to_i)
        .size
      break if days[day] == 0

      streak += 1
      comment_count += days[day]
    end
    [streak, comment_count]
  end

  def streak(span = 365)
    note_streak = self.note_streak(span)
    wiki_edit_streak = self.wiki_edit_streak(span)
    comment_streak = self.comment_streak(span)
    streak_count = [note_streak[1], wiki_edit_streak[1], comment_streak[1]]
    streak = [note_streak[0], wiki_edit_streak[0], comment_streak[0]]
    [streak.max, streak_count]
  end
end
