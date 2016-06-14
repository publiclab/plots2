class Search < ActiveRecord::Base

  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :key_words, :title, :main_type, :note_type, :date_created, :created_by

  ## current advanced search
  def advanced_search(input, params)
    all = !params[:notes] && !params[:wikis] && !params[:maps] && !params[:comments]
    @nodes = []
    unless input.blank?
      @nodes += SearchService.new.find_notes(input, 25) if params[:notes] || all
      @nodes += SearchService.new.find_maps(input, 25) if params[:maps] || all
      @nodes += SearchService.new.find_comments(input, 25) if params[:comments] || all
      @nodes += DrupalNode.limit(25)
                    .order("nid DESC")
                    .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', "%" + input + "%") if params[:wikis] || all
    end
  end
end
