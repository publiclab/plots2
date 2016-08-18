class SeedSlugsColumn < ActiveRecord::Migration
  def change
  	DrupalNode.find_each(&:save)
  end
end
