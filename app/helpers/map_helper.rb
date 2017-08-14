# frozen_string_literal: true
module MapHelper
  def map_access_token
    JSON.parse(
      HTTParty
        .post(
          "https://api.mapbox.com/tokens/v2/#{ENV['MAPBOX_USERNAME']}?access_token=#{ENV['MAPBOX_KEY']}",
          body: {
            expires: 59.minutes.from_now,
            scopes: ['styles:tiles', 'styles:read', 'fonts:read', 'datasets:read']
          }.to_json,
          headers: {'Content-Type': 'application/json'}
        )
        .body
    )['token']
  end

  def map_marker_props(placement)
    {
      lat: placement.lat,
      lon: placement.lon,
      icon: {
        iconUrl: image_url('marker-icon.png'),
        iconAnchor: [13, 44]
      }
    }
  end

  def map_picker_props(resource)
    marker = resource.edge.placements.custom.first
    if marker.nil?
      center = Placement.find_by_path(resource.persisted_edge&.path, %w(custom country)) ||
        Place.find_or_fetch_country('nl')
    end
    {
      accessToken: map_access_token,
      icon: {
        iconUrl: image_url('marker-icon.png'),
        iconAnchor: [13, 44]
      },
      centerLat: marker&.lat || center.lat,
      centerLon: marker&.lon || center.lon,
      initialZoom: marker&.zoom_level || center.zoom_level,
      markerId: marker&.id,
      markerLat: marker&.lat,
      markerLon: marker&.lon,
      markerType: 'custom',
      required: resource.is_a?(Motion) && resource.parent_model.try(:require_location?),
      resourceType: resource.class_name.singularize
    }
  end

  def map_viewer_props(markers)
    markers = [markers] unless markers.is_a?(Array)
    center_lat = markers.map { |marker| marker[:lat] }.sum / markers.size.to_f
    center_lon = markers.map { |marker| marker[:lon] }.sum / markers.size.to_f
    {
      accessToken: map_access_token,
      centerLat: center_lat,
      centerLon: center_lon,
      initialZoom: 13,
      markers: markers
    }
  end
end
