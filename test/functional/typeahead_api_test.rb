require 'test_helper'
require 'rest-client'

class TypeaheadApiTest < ActionController::TestCase

  def setup
    @stxt = 'lat'
    @sseq = 7
    @qstring = 'srchString=lat&seq=7'
  end


end
