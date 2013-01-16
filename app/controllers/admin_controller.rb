class AdminController < ApplicationController

  def spam
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 0}, :page => params[:page])
  end

  def geocode
    succeeded = 0
    failed = 0
    @users = DrupalUsers.locations.each do |user|
      if user.geocode
        succeeded += 1
      else
        failed += 1
      end
    end 
    render :text => succeeded.to_s+' OK, '+failed.to_s+' failed'
  end

end
