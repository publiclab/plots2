class AddImagesToRevisionBody < ActiveRecord::Migration[5.2]
  def change
    Revision.all.each do |rev|
      rev.node.gallery.each do |image|
        html = "<a target='_blank' href='#{image.image.path(:original)}'><img rel='tooltip' data-title='#{image.description}' style='margin-bottom:4px;' class='img-rounded' src='#{image.image.path(:thumb)}' /></a>"
        rev.body = html + rev.body
      end
    end
  end
end
