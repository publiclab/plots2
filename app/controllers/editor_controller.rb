class EditorController < ApplicationController

  before_filter :require_user, :only => [:post]

  # main image via URL passed as GET param
  def post
    if params[:newsletter]
      params[:tags] = "newsletter"
      # last newsletter
      @newsletter = DrupalNode.where('type = "note" AND status = 1 AND term_data.name = ?', 'newsletter')
                              .includes(:drupal_tag)
                              .order('node.nid DESC')
                              .limit(1)
                              .first

      if  @newsletter.nil?
        last = DateTime.new.to_s # there's never been a newsletter
      else
        last = @newsletter.created
      end

      # nids already used
      already = [0]
      @all = DrupalNode.where('type = "note" AND status = 1 AND created > ?',last)
                       .includes(:drupal_tag)
                       .limit(20)


      # filter just events
      @events = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name = ?', last, 'event')
                          .includes(:drupal_tag)
                          .limit(20)

      already += @events.collect(&:nid)

      # filter places by whitelist
      tids = DrupalTag.find(:all, :conditions => {:name => 'chapter'}).collect(&:tid)
      placenames = DrupalNodeCommunityTag.find(:all, :conditions => ["tid IN (?)",tids]).collect(&:node).collect(&:slug)
      @places = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name IN (?)', last, placenames)
                          .includes(:drupal_tag)
                          .limit(20)

      already += @places.collect(&:nid)

      # everything else
      @notes = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND nid NOT IN (?)', last, already)
                         .includes(:drupal_tag)
                         .limit(20)


      # get barnstars
      @barnstars = DrupalNode.where('type = "note" AND status = 1 AND created > ? AND term_data.name LIKE (?)', last, 'barnstar:%')
                             .includes(:drupal_tag)
                             .limit(20)

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
