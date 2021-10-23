Paperclip.options[:content_type_mappings] = { 
  kml: 'application/xml', 
  kmz: 'application/octet-stream', 
  gpx: 'application/xml', 
  lut: 'application/octet-stream', 
  stl: 'application/octet-stream',
  dxf: 'application/octet-stream',
  csv: ['application/octet-stream', 'text/plain']
}
Paperclip::DataUriAdapter.register
Paperclip::Attachment.default_options[:storage] = :fog
Paperclip::Attachment.default_options[:fog_directory] = ENV["GOOGLE_STORAGE_BUCKET_NAME"] || ''
Paperclip::Attachment.default_options[:path] = ":rails_root/public/system/public/system/:class/:attachment/:id_partition/:style/:filename"
Paperclip::Attachment.default_options[:fog_credentials] = {
    provider: ENV["FOG_PROVIDER"] || "Local",
    local_root: "#{Rails.root}/public",
    google_project: 'public-lab' ,
    google_json_key_location: ENV["GOOGLE_JSON_KEY_FILE"] || ''
}
Paperclip::Attachment.default_options[:fog_host] = ""
