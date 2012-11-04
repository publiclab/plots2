class AdminController < ApplicationController

  def spam
    @nodes = DrupalNode.paginate(:order => "nid DESC", :conditions => {:type => 'note', :status => 0}, :page => params[:page])
  end

end
