ulass UserController < ApplicationController

  def rss
    if params[:author]
      @author = DrupalUsers.find_by_name params[:author]
      if @author
        @notes = DrupalNode.find(:all,:order => "nid DESC", :conditions => {:type => 'note', :status => 1, :uid => @author.uid},:limit => 20)
      else
        flash[:error] = "No user by that name found"
        redirect_to "/"
      end
    else
    end
    respond_to do |format|
      format.rss {
        render :layout => false
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
      } 
    end
  end

end
