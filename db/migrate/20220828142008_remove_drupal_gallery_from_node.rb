class RemoveDrupalGalleryFromNode < ActiveRecord::Migration[5.2]
  def change
    Node.all.each do |node|
      new_revision = node.revisions.first.dup
      gallery_images = ""
      node.gallery.each do |image|
        html = "<a target='_blank' href='#{image&.image&.path(:original)}'><img rel='tooltip' data-title='#{image&.description}' style='margin-bottom:4px;' class='rounded' src='#{image&.image&.path(:thumb)}' /></a>"
        gallery_images << html
      end
      new_revision.body = gallery_images + new_revision.body
      new_revision.save!
    end
  end
end
