class EditorController < ApplicationController

  before_filter :require_user, :only => [:post]

  # main image via URL passed as GET param
  def post
    if params[:newsletter]
      params[:tags] = "newsletter"
      # last newsletter
      newsletter = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name = ?',(Time.now.to_i-1.weeks.to_i).to_s,'newsletter').includes(:drupal_tag).last

      if  newsletter.nil?
        last = DateTime.new
      else
        last = newsletter.created 
      end

      # nids already used
      already = []
      @all = DrupalNode.where('type = "note" AND status = 1 AND created > ?',last.to_s).includes(:drupal_tag)

      # filter just events
      @events = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name = ?',last.to_s,'event').includes(:drupal_tag)
      already += @events.collect(&:nid)

      # filter places by whitelist
      tids = DrupalTag.find(:all, :conditions => {:name => 'chapter'}).collect(&:tid)
      placenames = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:node).collect(&:slug)
      @places = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name IN (?)',last.to_s,placenames).includes(:drupal_tag)
      already += @places.collect(&:nid)

      # everything else
      @notes = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND nid NOT IN (?)',last.to_s, already).includes(:drupal_tag)

      # get barnstars
      @barnstars = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name LIKE (?)',last.to_s,'barnstar:%').includes(:drupal_tag)
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
