class AddFirstTagPoster < ActiveRecord::Migration[5.1]
  def find_and_update
    nids = []
    User.includes(:node).where(node: { status: 1 }).each do |user|
      if user.nodes.count > 1
        nids << user.nodes.first.id
      end
    end
    plotsbot = User.find_by(username: 'plotsbot')
    Node.find(nids).each do |node|
      node.add_tag('first-time-poster', plotsbot)
    end
  end

  def up
    find_and_update
  end
end
