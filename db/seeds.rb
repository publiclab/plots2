# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# set up a tag for all_notes subscription
everything_tag = Tag.create! "name"=>"everything", "description"=>"", "weight"=>0

# set up 3 basic users: admin, mod, and user
admin = User.create! "username"=>"admin", "email"=>"admin@example.com",
  "openid_identifier"=>nil, "password"=>"password",
  "password_confirmation"=>"password"
admin.role = "admin"
admin.save({})

mod = User.create! "username"=>"moderator", "email"=>"moderator@example.com",
  "password"=>"password", "password_confirmation"=>"password"
mod.role = "moderator"
mod.save({})

basic_user = User.create! "username"=>"user", "email"=>"user@example.com",
  "password"=>"password", "password_confirmation"=>"password"
basic_user.role = "basic"
basic_user.save({})

# set up some records, otherwise rails will throw errors on visiting these pages
%w{about media events getting-started donate stats licenses}.each do |page|
  web_page = Node.create! "type"=>"page", "title"=>page.capitalize, "uid"=>admin.id,
    "status"=>1, "comment"=>0, "cached_likes"=>0
  #web_node_counter = DrupalNodeCounter.create! "nid"=>web_page.nid,
    #"totalcount"=>1
  web_node_revisions = Revision.create! "nid"=>web_page.nid,
    "uid"=>admin.uid, "title"=>page.capitalize, "body"=>"#{page} - page", "teaser"=>"",
    "log"=>"", "format"=>1
end

# set up a blog entry with a comment and a like
blog_post = Node.create! "type"=>"note", "title"=>"Blog Post", "uid"=>admin.id,
  "status"=>1, "comment"=>1, "cached_likes"=>1
blog_post_revisions = Revision.create! "nid"=>blog_post.nid,
    "uid"=>admin.uid, "title"=>"Blog Post", "body"=>"Blog post body", "teaser"=>"",
    "log"=>"", "format"=>1
blog_post_tag = Tag.create! "name"=>"blog", "description"=>"", "weight"=>0
blog_post_community_tag = NodeTag.create! "tid"=>blog_post_tag.id,
  "nid"=>blog_post.id, "uid"=>admin.id
blog_post_comment = Comment.create! "nid"=>blog_post.id, "uid"=>admin.id,
  "subject"=>"", "comment"=>"Example Comment\r\n", "hostname"=>"", "status"=>0,
  "format"=>1, "thread"=>"01/"

# Create 35 maps for the /maps sections
35.times do |t|
  map_node = Node.create! "type"=>"map", "title"=>"test map #{t}", "uid"=>1,
    "status"=>1
  Revision.attr_accessible :nid, :vid
  map_node_revision =  Revision.create! "nid" => map_node.nid, "vid" => map_node.nid,
    "uid"=>1, "title"=>"Test Map #{t}", "body"=>"Body of revision #{t}" 
  tag_lat = Tag.create! name: "lat:#{rand * 80}", description: "Desc #{t}", weight: 5
  tag_lon = Tag.create! name: "lon:#{rand * 80}", description: "Desc #{t}", weight: 5
  drupal_comm_tag_lat = NodeTag.create! nid: map_node.nid, tid: tag_lat.tid, uid: 1
  drupal_comm_tag_lon = NodeTag.create! nid: map_node.nid, tid: tag_lon.tid, uid: 1
  DrupalContentTypeMap.attr_accessible :nid, :vid, :field_publication_date_value, :field_capture_date_value, :field_tms_url_value, :field_license_value, :field_raw_images_value, :field_cartographer_notes_value, :field_notes_value, :field_zoom_min_value, :field_zoom_max_value, :authorship
  content_type_mape = DrupalContentTypeMap.create! "vid"=>map_node.nid,
    "nid"=>map_node.nid, "field_publication_date_value"=>Time.now.to_s(:short),
    "field_capture_date_value"=>Time.now.to_s(:short),
    "field_tms_url_value"=>"http://archive.publiclaboratory.org/leaflet/?\
    tms=http://archive.publiclab.org/2013/2013-04-15-us-massachusetts-plum-\
    island/tms/&lon=-70.80848&lat=42.7952&zoom=16", "field_license_value"=>"publicdomain",
    "field_raw_images_value"=>"", "field_cartographer_notes_value"=>"No notes",
    "field_notes_value"=>"No note value",  "field_zoom_min_value"=>1,
    "field_zoom_max_value"=>14, "authorship"=>"Admin"
end
