class EditorController < ApplicationController

  before_filter :require_user, :only => [:post]

end
