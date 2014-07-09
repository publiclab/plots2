class EditorController < ApplicationController

  before_filter :require_user, :only => [:post]

  # main image via URL passed as GET param
  def post
    if params[:newsletter]
      # nids already used
      already = []
      # filter just events
      @events = DrupalNode.find :all, :conditions => ['type = "note" AND status = 1 AND created > '+(Time.now.to_i-1.weeks.to_i).to_s]
      already += @events.collect(&:nid)
      # filter just events
      @notes = DrupalNode.find :all, :conditions => ['type = "note" AND status = 1 AND nid NOT IN (?) AND created > '+(Time.now.to_i-1.weeks.to_i).to_s,already]
    end
    # /post/?i=http://myurl.com/image.jpg
    if params[:i]
      @image = Image.new({
        :remote_url => params[:i],
        :uid => current_user.uid
      })
      flash[:error] = "The image could not be saved." unless @image.save!
    end
  end

end
