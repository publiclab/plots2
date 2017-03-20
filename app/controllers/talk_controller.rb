class TalkController < ApplicationController
  def show
    @node = Node.find_by_path params[:id]
  end
end
