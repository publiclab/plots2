class TalkController < ApplicationController
  def show
    @node = Node.find_by_path params[:id]
    @node = Node.find_by_path "wiki/#{params[:id]}" if @node.nil?
  end
end
