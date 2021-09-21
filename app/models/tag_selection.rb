class TagSelection < ApplicationRecord
  self.primary_keys = :user_id, :tid
  belongs_to :tag, foreign_key: :tid
  has_many :node_tags, foreign_key: :tid

  validates :user_id, presence: true
  validates :tid, presence: true
  validates :tag, presence: true

  def user
    User.find(user_id)
  end

  def ruser
    User.find(user_id)
  end

  def tagname
    tag.name
  end

  def self.graph(start = DateTime.now - 1.year, fin = DateTime.now)
    date_hash = {}
    week = start.to_date.step(fin.to_date, 7).count

    while week >= 1
      month = (fin - (week * 7 - 1).days)
      range = (fin - week.weeks)..(fin - (week - 1).weeks)
      weekly_subs = TagSelection.select(:following, :created_at)
                                .where(following: true, created_at: range)
                                .size
      date_hash[month.to_f * 1000] = weekly_subs
      week -= 1
    end
    date_hash
  end

  def self.start_tracking
    TagSelection.first&.updated_at&.to_date&.to_formatted_s(:long_ordinal)
  end
end
