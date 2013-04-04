class AdminController < ApplicationController

  before_filter :require_user, :only => [:spam]

  def spam
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 0}, :page => params[:page])
  end

  def geocode
    if current_user && current_user.username == "warren"
      succeeded = 0
      failed = 0
      if params[:all]
        @users = DrupalUsers.locations
      elsif params[:name]
        @users = DrupalUsers.find_all_by_name params[:name]
      else
        @users = DrupalUsers.find(:all, :conditions => ["lat = 0.0 AND profile_values.fid = 2 AND profile_values.value != ''"], :include => :drupal_profile_values)
      end
      @users.each do |user|
        if user.geocode
          succeeded += 1
        else
          failed += 1
        end
      end 
      render :text => succeeded.to_s+' OK, '+failed.to_s+' failed'
    else
      prompt_login "Only admins can view that page."
    end
  end

end
