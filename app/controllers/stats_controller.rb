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
    if params[:options].present?
      params[:start] = Time.now - to_keyword(params[:options])
      params[:end] = Time.now
    end
    @start = params[:start] ? Time.parse(params[:start].to_s) : Time.now - 1.month
    @end = params[:end] ? Time.parse(params[:end].to_s) : Time.now
    @notes = Node.published.select(%i(created type))
      .where(type: 'note', created: @start.to_i..@end.to_i)
      .count(:all)
    @wikis = Revision.select(:timestamp)
      .where(timestamp: @start.to_i..@end.to_i)
      .count - @notes # because notes each have one revision
    @people = User.where(created_at: @start..@end).where(status: 1)
      .count
    @answers = Answer.where(created_at: @start..@end)
      .count
    @comments = Comment.select(:timestamp)
      .where(timestamp: @start.to_i..@end.to_i)
      .count
    @questions = Node.published.questions.where(created: @start.to_i..@end.to_i)
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

    @weekly_notes = Node.past_week.select(:type).where(type: 'note').count(:all)
    @weekly_wikis = Revision.past_week.count
    @weekly_members = User.past_week.where(status: 1).count
    @monthly_notes = Node.past_month.select(:type).where(type: 'note').count(:all)
    @monthly_wikis = Revision.past_month.count
    @monthly_members = User.past_month.where(status: 1).count

    @notes_per_week_past_year = Node.past_year.select(:type).where(type: 'note').count(:all) / 52.0
    @edits_per_week_past_year = Revision.past_year.count / 52.0

    @graph_notes = Node.contribution_graph_making('note', 52, @time)
    @graph_wikis = Node.contribution_graph_making('page', 52, @time)
    @graph_comments = Comment.contribution_graph_making(52, @time)

    users = []
    nids = []
    Node.published.where(type: 'note').each do |note|
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

  def stats_json
    @hash = {}

    @nodes = Node.where(status: 1).select(:type).uniq
    @nodes.each do |n|
      puts @hash[n.type] = Node.where(type: n.type, status: 1).to_json
    end
  end

  def notes
    export_as_json('note')
  end

  def wikis
    export_as_json('wiki')
  end

  private

  def export_as_json(type)
    data = Node.where(type: type, status: 1).all.to_json
    send_data data, :type => 'application/json; header=present', :disposition => "attachment; filename=#{type}.json"
  end

  def to_keyword(param)
    1.send(param.downcase)
  end
end
