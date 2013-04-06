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

  factory :drupal_node do

    nid 1
    title "A new idea for DIY spectrometry"
    #association :drupal_node_revision

    #factory :node_revision do
    #  nid 1
    #  title "A new idea for DIY spectrometry"
    #end

  end
end

