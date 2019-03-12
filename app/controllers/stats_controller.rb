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
    @popular_tags = Tag.nodes_frequency(@start, @end)
  end

  def index
    range
    if @start > @end
      flash.now[:warning] = "Start date must come before end date"
    end
    @title = 'Stats'

    @weekly_notes = Node.past_week.select(:type).where(type: 'note').count(:all)
    @weekly_wikis = Revision.past_week.count
    @weekly_questions = Node.questions.past_week.count(:all).count
    @weekly_answers = Answer.past_week.count
    @weekly_members = User.past_week.where(status: 1).count
    @monthly_notes = Node.past_month.select(:type).where(type: 'note').count(:all)
    @monthly_wikis = Revision.past_month.count
    @monthly_members = User.past_month.where(status: 1).count
    @monthly_questions = Node.questions.past_month.count(:all).count
    @monthly_answers = Answer.past_month.count

    @notes_per_week_past_year = Node.past_year.select(:type).where(type: 'note').count(:all) / 52.0
    @edits_per_week_past_year = Revision.past_year.count / 52.0

    @graph_notes = Node.contribution_graph_making('note', @start, @end)
    @graph_wikis = Node.contribution_graph_making('page', @start, @end)
    @graph_comments = Comment.contribution_graph_making(@start, @end)

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

  def notes
    time
    export_as_json(@start, @end, 'note')
  end

  def wikis
    time
    export_as_json(@start, @end, 'page')
  end

  def users
    time
    data = User.where(created_at: @start..@end).where(status: 1)
    respond_to do |format|
      format.csv { send_data data.to_csv }
      format.json { send_data data.to_json, type: 'application/json; header=present', disposition: "attachment; filename=user.json" }
    end
  end

  def questions
    time
    data = Node.published.questions.where(created: @start.to_i..@end.to_i).all
    respond_to do |format|
      format.csv { send_data data.to_csv }
      format.json { send_data data.to_json, type: 'application/json; header=present', disposition: "attachment; filename=questions.json" }
    end
  end

  def answers
    time
    data = Answer.where(created_at: @start..@end).all
    respond_to do |format|
      format.csv { send_data data.to_csv }
      format.json { send_data data.to_json, type: 'application/json; header=present', disposition: "attachment; filename=answers.json" }
    end
  end

  def comments
    time
    data = Comment.select(%i(status timestamp)).where(status: 1, timestamp: @start.to_i...@end.to_i).all
    respond_to do |format|
      format.csv { send_data data.to_csv }
      format.json { send_data data.to_json, type: 'application/json; header=present', disposition: "attachment; filename=comment.json" }
    end
  end

  def export_as_json(starting, ending, type)
    data = Node.published.select(%i(created type))
      .where(type: type, created: starting.to_i..ending.to_i)
      .all
    respond_to do |format|
      format.csv { send_data data.to_csv }
      format.json { send_data data.to_json, type: 'application/json; header=present', disposition: "attachment; filename=#{type}.json" }
    end
  end

  private

  def time
    @start = params[:start] ? Time.parse(params[:start].to_s) : Time.now - 1.month
    @end = params[:end] ? Time.parse(params[:end].to_s) : Time.now
  end

  def to_keyword(param)
    str =  param.split.second
    1.send(str.downcase)
  end
end
