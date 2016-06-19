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

  def nodes
    @nodes ||= find_nodes
  end

  private

  def find_nodes
    DrupalNode.all(conditions: conditions)
  end

  def keyword_conditions
    ["nodes.title LIKE ?", "%#{key_words}%"] unless key_words.blank?
  end

  # def minimum_price_conditions
  #   ["nodes.price >= ?", minimum_price] unless minimum_price.blank?
  # end

  def type_conditions
    ["nodes.type = ?", note_type] unless note_type.blank?
  end

  ## Query assembling methods
  def conditions
    [conditions_clauses.join(' AND '), *conditions_options]
  end

  def conditions_clauses
    conditions_parts.map { |condition| condition.first }
  end

  def conditions_options
    conditions_parts.map { |condition| condition[1..-1] }.flatten
  end

  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end
end
