class TalkController < ApplicationController
  def show
    @node = DrupalNode.find_by_slug params[:id]
  end
end
