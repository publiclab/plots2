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
Paperclip::Attachment.default_options[:fog_directory] = ENV["GOOGLE_STORAGE_BUCKET_NAME"]
#Paperclip::Attachment.default_options[:path] = "public/system" # this is set by paperclip already
# the following we do in the image model at /app/models/image.rb
#Paperclip::Attachment.default_options[:fog_credentials] = { provider: "Local", local_root: "#{Rails.root}/public"}
# the following are for local storage:
#Paperclip::Attachment.default_options[:fog_host] = "http://localhost:3000"
