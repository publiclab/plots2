require Rails.root + 'lib/dynamic_form/action_view/helpers/dynamic_form.rb'

class ActionView::Base
  include DynamicForm
end
