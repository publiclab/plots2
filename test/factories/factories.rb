class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

# this includes defaults which can be overridden
FactoryGirl.define do
  factory :user do
    username "warren"
    password "secret"
    password_confirmation { |u| u.password }
    email "jeff@unterbahn.com"
  end

  factory :drupal_users do
    uid 1
    name "warren"
    mail "jeff@unterbahn.com"
  end

  factory :drupal_node do
    title "A new idea for DIY spectrometry"
    uid 1
    type "note"
    #main_image 
    #association :drupal_node_revision

  end

  factory :drupal_node_revision do
    title "A new idea for DIY spectrometry"
    body "This is a really great improvement to the **Public Lab DIY spectrometer**."
    uid 1
  end

end

