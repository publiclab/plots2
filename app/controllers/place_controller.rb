require 'rss'

class PlaceController < ApplicationController

  def feed
    @feed = RSS::Parser.parse(open('https://groups.google.com/group/'+params[:id]+'/feed/rss_v2_0_topics.xml').read, false).items[0..4]
  end

end
