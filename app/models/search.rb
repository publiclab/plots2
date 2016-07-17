class Search < ActiveRecord::Base
  require 'date'
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :key_words, :title, :main_type, :note_type, :min_date, :created_by,
                  :language, :max_date

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
  def users(params)
    @users ||= find_users(params)
  end

  def date_i(date_param)
    Date.strptime(date_param, '%d-%m-%Y').to_time.to_i
  end

  def nodes
    @nodes ||= find_nodes
  end

  def notes
    solr_search = DrupalNode.search do
      fulltext self.key_words
    end
    @nodes = solr_search.results
  end

  private

  def find_nodes
    DrupalNode.find(:all, :conditions => conditions)
  end

  def keyword_conditions
    ['node.title LIKE ?', "%#{key_words}%"] unless key_words.blank?
  end

  def minimum_date_conditions
    ['node.created >= ?', date_i(min_date)] unless min_date.blank?
  end

  def maximum_date_conditions
    ['node.created <= ?', date_i(max_date)] unless max_date.blank?
  end

  def type_conditions
    ['node.type = ?', note_type] unless note_type.blank?
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
