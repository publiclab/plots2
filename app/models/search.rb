class Search < ActiveRecord::Base
  require 'date'
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :key_words, :title, :main_type, :note_type, :min_date, :created_by,
                  :language, :max_date

  def initialize; end

  def date_i(date_param)
    Date.strptime(date_param, '%d-%m-%Y').to_time.to_i
  end

  def nodes
    @nodes ||= find_nodes
  end

  def notes(month)
    solr_search = Node.search do
      fulltext key_words do
        fields(:title, :body) # can later add username, other fields, comments, maybe tags
      end
      with(:updated_at).less_than(Time.zone.now)
      facet(:updated_month)
      with(:updated_month, month) if month.present?
      paginate page: 1, per_page: 10
      # this is required to get results to return: 
      adjust_solr_params do |params|
        params[:qf] = nil
      end
    end
  end

  def note_results(month)
    @nodes = notes(month).results
  end

  private

  def find_nodes
    Node.find(:all, conditions: conditions)
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
    conditions_parts.map(&:first)
  end

  def conditions_options
    conditions_parts.map { |condition| condition[1..-1] }.flatten
  end

  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end
end
