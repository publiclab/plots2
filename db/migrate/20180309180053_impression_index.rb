class ImpressionIndex < ActiveRecord::Migration[5.1]
  def change
    add_index "impressions", ["impressionable_type"], name: "index_impressions_on_impressionable_type"
    add_index "impressions", ["impressionable_id"], name: "index_impressions_on_impressionable_id"
  end
end
