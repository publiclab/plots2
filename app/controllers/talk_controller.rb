class TalkController < ApplicationController
  def show
    @node = DrupalNode.find_by_path params[:id]
  end
end
