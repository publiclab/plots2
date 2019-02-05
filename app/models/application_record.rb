class ApplicationRecord < ActiveRecord::Base
  require 'csv'
  self.abstract_class = true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |object|
        csv << object.attributes.values_at(*column_names)
      end
    end
  end
end
