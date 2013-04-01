class LegacyController < ApplicationController

  def notes
    redirect_to "/tag/"+params[:id]
  end

  def note_add 
    redirect_to "/post"
  end

  def people
    redirect_to '/profile/'+params[:id]
  end

  def place
    redirect_to "/wiki/"+params[:id]
  end

  def tool
    redirect_to "/wiki/"+params[:id]
  end

end
