class RemoveDrupalGalleryFromNode < ActiveRecord::Migration[5.2]
  def change
    Node.all.each do |node|
      new_revision = node.revisions.first.dup
      gallery_images = ""
      gallery = DrupalContentFieldImageGallery.where(nid: node.nid)
        .order('field_image_gallery_fid')
      gallery.each do |image|
        unless image.nil? || image.field_image_gallery_fid.nil? || image.image.nil? || image.image.path.nil?
          html = "<a target='_blank' href='#{image&.image&.path(:original)}'><img rel='tooltip' data-title='#{image&.description}' style='margin-bottom:4px;' class='rounded' src='#{image&.image&.path(:thumb)}' /></a>"
          gallery_images << html
        end
      end
      new_revision.body = gallery_images + new_revision.body
      new_revision.save! unless new_revision.body.empty?
    end
  end
end
