class StatsController < ApplicationController

  def subscriptions
    @tags = {}
    TagSelection.where(following: true).each do |tag|
      @tags[tag.name] = @tags[tag.name] || 0
      @tags[tag.name] += 1
    end
    render text: @tags.inspect
  end

  def range
    @start = params[:start] ? Time.parse(params[:start]) : Time.now - 1.month
    @end = params[:end] ? Time.parse(params[:end]) : Time.now
    @notes = Node.select([:created, :type, :status])
                       .where(type: 'note', status: 1, created: @start.to_i..@end.to_i)
                       .count
    @wikis = DrupalNodeRevision.select(:timestamp)
                               .where(timestamp: @start.to_i..@end.to_i)
                               .count - @notes # because notes each have one revision
    @people = User.where(created_at: @start..@end)
                  .count
  end

  def index
    if params[:time]
      @time = Time.parse(params[:time])
    else
      @time = Time.now
    end

    @weekly_notes = Node.select([:created, :type, :status])
                              .where(type: 'note', status: 1, created: @time.to_i - 1.weeks.to_i..@time.to_i)
                              .count
    @weekly_wikis = DrupalNodeRevision.select(:timestamp)
                                      .where(timestamp: @time.to_i - 1.weeks.to_i..@time.to_i)
                                      .count
    @weekly_members = User.where(created_at: @time - 1.weeks..@time)
                          .count
    @monthly_notes = Node.select([:created, :type, :status])
                               .where(type: 'note', status: 1, created: @time.to_i - 1.months.to_i..@time.to_i)
                               .count
    @monthly_wikis = DrupalNodeRevision.select(:timestamp)
                                       .where(timestamp: @time.to_i - 1.months.to_i..@time.to_i)
                                       .count
    @monthly_members = User.where(created_at: @time - 1.months..@time)
                           .count

    @notes_per_week_past_year = Node.select([:created, :type, :status])
                                          .where(type: 'note', status: 1, created: @time.to_i - 1.years.to_i..@time.to_i)
                                          .count / 52.0
    @edits_per_week_past_year = DrupalNodeRevision.select(:timestamp)
                                                  .where(timestamp: @time.to_i - 1.years.to_i..@time.to_i)
                                                  .count / 52.0

    @graph_notes = Node.weekly_tallies('note', 52, @time).to_a.sort.to_json
    @graph_wikis = Node.weekly_tallies('page', 52, @time).to_a.sort.to_json
    @graph_comments = Comment.comment_weekly_tallies(52, @time).to_a.sort.to_json

    users = []
    nids = []
    Node.find(:all, :conditions => {:type => 'note', :status => 1}).each do |note|
      unless note.uid == 674 || note.uid == 671
        users << note.uid
        nids << note.nid
      end
    end

    @all_notes = nids.uniq.length
    @all_contributors = users.uniq.length
  end

end
