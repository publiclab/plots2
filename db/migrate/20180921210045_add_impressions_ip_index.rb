class AddImpressionsIpIndex < ActiveRecord::Migration[5.2]
  def change
    add_index "impressions", ["ip_address"], name: "index_impressions_on_ip_address"
  end
end
