# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# set up a tag for all_notes subscription
everything_tag = DrupalTag.create! "name"=>"everything", "description"=>"", "weight"=>0, "tid"=>0

# set up 3 basic users: admin, mod, and user
admin = User.create! "username"=>"admin", "email"=>"admin@example.com", 
  "openid_identifier"=>nil, "password"=>"password", 
  "password_confirmation"=>"password"
admin.role = "admin"
admin.save({})
DrupalUsers.create! "name"=>"admin", 
  "mail"=>"admin@example.com", "mode"=>0, "sort"=>0, "threshold"=>0, 
  "theme"=>"", "signature"=>"", "signature_format"=>0, "status"=>1, 
  "timezone"=>nil, "language"=>"", "picture"=>"", "init"=>"", 
  "data"=>nil, "timezone_id"=>0, "timezone_name"=>"" 

mod = User.create! "username"=>"moderator", "email"=>"moderator@example.com", 
  "password"=>"password", "password_confirmation"=>"password"
mod.role = "moderator"
mod.save({})
DrupalUsers.create! "name"=>"moderator", 
  "mail"=>"moderator@example.com", "mode"=>0, "sort"=>0, "threshold"=>0, 
  "theme"=>"", "signature"=>"", "signature_format"=>0, "status"=>1, 
  "timezone"=>nil, "language"=>"", "picture"=>"", "init"=>"", 
  "data"=>nil, "timezone_id"=>0, "timezone_name"=>"" 

basic_user = User.create! "username"=>"user", "email"=>"user@example.com", 
  "password"=>"password", "password_confirmation"=>"password"
basic_user.role = "basic"
basic_user.save({})
DrupalUsers.create! "name"=>"user", 
  "mail"=>"user@example.com", "mode"=>0, "sort"=>0, "threshold"=>0, 
  "theme"=>"", "signature"=>"", "signature_format"=>0, "status"=>1, 
  "timezone"=>nil, "language"=>"", "picture"=>"", "init"=>"", 
  "data"=>nil, "timezone_id"=>0, "timezone_name"=>""

# set up some records, otherwise rails will throw errors on visiting these pages
%w{about media events getting-started donate stats licenses}.each do |page|
  web_page = DrupalNode.create! "type"=>"page", "title"=>page.capitalize, "uid"=>admin.id, 
    "status"=>1, "comment"=>0, "cached_likes"=>0
  web_url_alias = DrupalUrlAlias.create! "dst"=>page, "src"=>"node/#{web_page.nid}"
  #web_node_counter = DrupalNodeCounter.create! "nid"=>web_page.nid, 
    #"totalcount"=>1
  web_node_revisions = DrupalNodeRevision.create! "nid"=>web_page.nid,
    "uid"=>admin.uid, "title"=>page.capitalize, "body"=>"#{page} - page", "teaser"=>"", 
    "log"=>"", "format"=>1
end

# set up a blog entry with a comment and a like
blog_post = DrupalNode.create! "type"=>"note", "title"=>"Blog Post", "uid"=>admin.id,
  "status"=>1, "comment"=>1, "cached_likes"=>1
#blog_post_alias = DrupalUrlAlias.create! "dst"=>"notes/user/#{Date.today.strftime('%m-%d-%Y')}",
  #"src"=>"node/#{blog_post.nid}"
blog_post_revisions = DrupalNodeRevision.create! "nid"=>blog_post.nid,
    "uid"=>admin.uid, "title"=>"Blog Post", "body"=>"Blog post body", "teaser"=>"", 
    "log"=>"", "format"=>1
blog_post_tag = DrupalTag.create! "name"=>"blog", "description"=>"", "weight"=>0
blog_post_community_tag = DrupalNodeCommunityTag.create! "tid"=>blog_post_tag.id,
  "nid"=>blog_post.id, "uid"=>admin.id
blog_post_comment = DrupalComment.create! "nid"=>blog_post.id, "uid"=>admin.id,
  "subject"=>"", "comment"=>"Example Comment\r\n", "hostname"=>"", "status"=>0,
  "format"=>1, "thread"=>"01/"
