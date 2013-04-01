class EditorController < ApplicationController

  def post
    if current_user
    else
      prompt_login "You must be logged in to upload."
    end
  end

end
