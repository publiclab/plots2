class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

# this includes defaults which can be overridden
FactoryGirl.define do
  factory :user do
    username "warren"
    password "secret"
    password_confirmation { |u| u.password }
    sequence(:email) {|n| "person#{n}@example.com" }
    role "basic" #this is the default; needed here?

    # this doesn't work; we need a uid field on User; see user.rb
    #drupal_users do |u|
    #  FactoryGirl.create(:drupal_users,:name => u.username, :mail => u.email)
    #end
  end

  sequence :uid

  factory :drupal_users do
    uid { generate(:uid) }
    name "warren"
    sequence(:mail) {|n| "person#{n}@example.com" }
  end

  sequence :nid

  factory :drupal_node do
    sequence(:title) {|n|  "A new idea for DIY spectrometry, ##{n}" }
    #uid 1
    type "note"
    nid { generate(:nid) }
    #main_image 
    #association :drupal_node_revision
    #drupal_node_revision do |n|
    #  3.times do
    #    FactoryGirl.create(:drupal_node_revision, :nid => n.id) # optionally add traits: FactoryGirl.create(:book, :book_description)
    #  end
    #end
  end

  factory :drupal_node_revision do
    title "A new idea for DIY spectrometry"
    body "This is a really great improvement to the **Public Lab DIY spectrometer**."
    uid 1
  end

end

