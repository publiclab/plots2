class TalkController < ApplicationController
  def show
    @slug = params[:id]
  end
end
