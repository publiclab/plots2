class LocationTagsController < ApplicationController
  respond_to :html, :json, :xml

  def create
    @output = {
      status: false,
      errors: []
    }

    user = DrupalUsers.find_by_name(params[:id])

    if current_user.role == 'admin' || current_user.email == user.email
      if params[:type] && params[:value]
        location = params[:value]
        @address = location[:address]
        lat = location[:lat]
        long = location[:long]
        if lat.nil? || long.nil?
          if @address.nil?
            @output[:errors] << 'Invalid input. Try again'
          else
            # Fetch geolocation data using geocoder through address
            @geo_location = Geocoder.search(@address.to_s).first || ''
          end
        else
          # Fetch geolocation using geocoder through lat, long
          @geo_location = Geocoder.search("#{lat},#{long}").first || ''
        end

        if !@geo_location.nil? && @geo_location != ''
          lat = @geo_location.latitude if lat.nil?
          long = @geo_location.longitude if long.nil?
          # @geo_location holds complete information of location
          if user.location_tag
            @location_tag = user.location_tag.update_attributes(location: @address,
                                                                lat: lat,
                                                                lon: long,
                                                                country: @geo_location.country,
                                                                state: @geo_location.state,
                                                                city: @geo_location.city)

            @output[:status] = @location_tag ? true : false
            @location_tag = user.location_tag
          else
            @location_tag = user.build_location_tag(location: @address,
                                                    lat: lat,
                                                    lon: long,
                                                    country: @geo_location.country,
                                                    state: @geo_location.state,
                                                    city: @geo_location.city)
            @output[:status] = @location_tag.save ? true : false
          end
        elsif @geo_location.nil?
          @output[:errors] << 'Cannot fetch location.'
        end

      else
        @output[:errors] << 'Invalid user input'
      end

    else
      # Handle Unauthorization case
      @output[:errors] << 'Only admin (or) target user can manage tags'
    end

    respond_to do |format|
      if request.xhr?
        format.json do
          render json: {
            status: @output[:status],
            location: @location_tag,
            location_privacy: user.user.location_privacy,
            name: user.name,
            errors: @output[:errors]
          }.to_json
        end
      else
        if !@output[:errors].empty?
          flash[:error] = "#{@output[:errors].length} errors have occured"
        else
          flash[:notice] = 'Location saved successfully'
        end
        redirect_to info_path, id: params[:id]

      end
    end
  end
end
