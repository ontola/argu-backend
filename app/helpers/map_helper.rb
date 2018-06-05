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
      },
      popup: {
        header: {
          class: "#{placement.placeable.try(:owner_type).underscore}-t",
          href: placement.placeable.iri,
          text: placement.placeable.display_name
        }
      }
    }
  end

  def map_picker_props(resource)
    marker = resource.custom_placements.first
    if marker.nil?
      center = Placement.find_by_path(resource.persisted_edge&.path, %w[custom country]) ||
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

  def map_question_props(resource)
    popup_link = new_iri(resource, :motions)
    popup_link.query = 'lat={lat}&lon={lon}&zoom_level={zoom}'.encode(Encoding::UTF_8)
    map_viewer_props(
      Placement
        .custom
        .joins('INNER JOIN edges ON edges.uuid = placements.placeable_id AND placements.placeable_type = \'Edge\'')
        .where(edges: {owner_id: @all_motion_edges.pluck(:owner_id)})
        .includes(:place, placeable: {parent: :shortname})
        .map { |placement| map_marker_props(placement) },
      popup: {
        header: {
          href: popup_link.to_s,
          fa: 'lightbulb-o',
          text: t('add_type', type: motion_type)
        }
      },
      center_lat: resource.custom_placements.first&.lat,
      center_lon: resource.custom_placements.first&.lon,
      zoom: resource.custom_placements.first&.zoom_level
    )
  end

  def map_viewer_props(markers, opts = {})
    markers = [markers] unless markers.is_a?(Array)
    center_lat = opts[:center_lat] || markers.map { |marker| marker[:lat] }.sum / markers.size.to_f
    center_lon = opts[:center_lon] || markers.map { |marker| marker[:lon] }.sum / markers.size.to_f
    {
      accessToken: map_access_token,
      centerLat: center_lat,
      centerLon: center_lon,
      initialZoom: opts[:zoom] || 13,
      markers: markers
    }.merge(opts)
  end
end
