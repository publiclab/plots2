class Like < ActiveRecord::Base
	belongs_to :likeable, polymorphic: true
end
