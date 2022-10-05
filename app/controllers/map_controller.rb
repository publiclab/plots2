class MapController < ApplicationController
  def map
    @lat = 0
    @lon = 0
    @zoom = 10

    if current_user&.has_power_tag("lat") && current_user&.has_power_tag("lon")
      @lat = current_user.get_value_of_power_tag("lat").to_f
      @lon = current_user.get_value_of_power_tag("lon").to_f
    end
    @zoom = current_user.get_value_of_power_tag("zoom").to_f if current_user&.has_power_tag("zoom")
  end

  def wiki
    @node = Node.find_wiki(params[:id])

    if @node.blank? || @node.has_power_tag("lat").blank? || @node.has_power_tag("lon").blank?
      flash[:warning] = @node.blank? ? "Wiki page not found." : "No location found for wiki page."
      redirect_to controller: 'map', action: 'map'
      return
    end

    @lat = @node.power_tag("lat").to_f
    @lon = @node.power_tag("lon").to_f
    @zoom = @node.has_power_tag("zoom") ? @node.power_tag("zoom").to_f : 6

    render :map
  end

end
