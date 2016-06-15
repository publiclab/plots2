class LocationTagsController < ApplicationController
  respond_to :html, :json, :xml

  def create
    @output = {
      status: false,
      errors: []
    }

    user = User.find_by_username(params[:id])

    if current_user.role == "admin" || current_user == user
      if params[:type] && params[:value]
        location = params[:value]
        @address = location[:address]
        lat, long = location[:lat], location[:long]
        if lat.nil? && long.nil?
          if address.nil?
            @output[:errors] << "Invalid input. Try again" 
          else
            # Fetch geolocation data using geocoder through address
            @geo_location = Geocoder.search("#{@address}").first || ""
          end
        else
          # Fetch geolocation using geocoder through lat, long
          @geo_location = Geocoder.search("#{lat},#{long}").first || ""
        end

        if @geo_location != ""
          # @geo_location holds complete information of location
          @location_tag = user.location_tags.build({
            location: @address,
            lat: lat,
            long: long,
            country: @geo_location.country,
            state: @geo_location.state,
            city: @geo_location.city
          })
          @output[:status] = @location_tag.save ? true : false
        else
          @output[:errors] << "Cannot fetch location."
        end

      else
        @output[:errors] << "Invalid user input"
      end
      
    else
      # Handle Unauthorization case
      @output[:errors] << "Only admin (or) target user can manage tags"
    end

    respond_with do |format|

      if request.xhr?
        render json: {
          status: true,
          location: @location_tag,
          errors: @output[:errors]
        }
      else
        
        if @output[:errors].length > 0
          flash[:error] = "#{@output[:errors].length} errors have occured"
        else
          flash[:notice] = "Location saved successfully"
        end
        redirect_to info_path, :id => params[:id]
      end
    end
  end

  def destroy
  end
end
