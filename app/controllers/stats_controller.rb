class StatsController < ApplicationController
  def subscriptions
    @tags = {}
    TagSelection.where(following: true).each do |tag|
      @tags[tag.tagname] = @tags[tag.tagname] || 0
      @tags[tag.tagname] += 1
    end
    render plain: @tags.inspect, status: 200
  end

  def range
    @start = params[:start] ? Time.parse(params[:start]) : Time.now - 1.month
    @end = params[:end] ? Time.parse(params[:end]) : Time.now
    @notes = Node.select(%i(created type status))
      .where(type: 'note', status: 1, created: @start.to_i..@end.to_i)
      .count(:all)
    @wikis = Revision.select(:timestamp)
      .where(timestamp: @start.to_i..@end.to_i)
      .count - @notes # because notes each have one revision
    @people = User.where(created_at: @start..@end)
      .joins('INNER JOIN users ON users.uid = rusers.id')
      .where('users.status = 1')
      .count
    @answers = Answer.where(created_at: @start..@end)
      .count
    @comments = Comment.select(:timestamp)
      .where(timestamp: @start.to_i..@end.to_i)
      .count
    @questions = Node.questions.where(status: 1, created: @start.to_i..@end.to_i)
      .count
    @contributors = User.contributor_count_for(@start, @end)
  end

  def index
    @title = 'Stats'
    @time = if params[:time]
              Time.parse(params[:time])
            else
              Time.now
    end

    @weekly_notes = Node.select(%i(created type status))
      .where(type: 'note', status: 1, created: @time.to_i - 1.weeks.to_i..@time.to_i)
      .count(:all)
    @weekly_wikis = Revision.select(:timestamp)
      .where(timestamp: @time.to_i - 1.weeks.to_i..@time.to_i)
      .count
    @weekly_members = User.where(created_at: @time - 1.weeks..@time)
      .joins('INNER JOIN users ON users.uid = rusers.id')
      .where('users.status = 1')
      .count
    @monthly_notes = Node.select(%i(created type status))
      .where(type: 'note', status: 1, created: @time.to_i - 1.months.to_i..@time.to_i)
      .count(:all)
    @monthly_wikis = Revision.select(:timestamp)
      .where(timestamp: @time.to_i - 1.months.to_i..@time.to_i)
      .count
    @monthly_members = User.where(created_at: @time - 1.months..@time)
      .joins('INNER JOIN users ON users.uid = rusers.id')
      .where('users.status = 1')
      .count

    @notes_per_week_past_year = Node.select(%i(created type status))
      .where(type: 'note', status: 1, created: @time.to_i - 1.years.to_i..@time.to_i)
      .count(:all) / 52.0
    @edits_per_week_past_year = Revision.select(:timestamp)
      .where(timestamp: @time.to_i - 1.years.to_i..@time.to_i)
      .count / 52.0

    @graph_notes = Node.contribution_graph_making('note', 52, @time).to_a.to_json
    @graph_wikis = Node.contribution_graph_making('page', 52, @time).to_a.to_json
    @graph_comments = Comment.contribution_graph_making(52, @time).to_a.to_json

    users = []
    nids = []
    Node.where(type: 'note', status: 1).each do |note|
      unless note.uid == 674 || note.uid == 671
        users << note.uid
        nids << note.nid
      end
    end

    @all_notes = nids.uniq.length
    @all_contributors = users.uniq.length
    Rails.cache.fetch("total-contributors-all-time", expires_in: 1.weeks) do
      @all_time_contributors = User.count_all_time_contributor
    end
  end
end
