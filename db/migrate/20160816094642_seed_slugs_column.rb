class SeedSlugsColumn < ActiveRecord::Migration
  def change
    # used to seed `friendly_id` slugs, but removed due to issues discussed in https://github.com/publiclab/plots2/issues/691
    # DrupalNode.find_each(&:save)
  end
end
