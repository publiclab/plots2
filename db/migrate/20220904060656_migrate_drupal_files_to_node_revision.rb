class MigrateDrupalFilesToNodeRevision < ActiveRecord::Migration[5.2]
  def change
    Node.all.each do |node|
      new_revision = node.revision.last
      file_links = "<ul>"
      node.files.each do |file|
        file_links << "<li><a href='#{file.filepath}'>#{file&.filename}</a></li>"
      end
      file_links << "</ul>"
      new_revision.body << file_links
      new_revision.save!
    end
  end
end
