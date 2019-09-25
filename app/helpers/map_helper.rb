# frozen_string_literal: true

module MapHelper
  def map_access_token(times = 0)
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
  rescue JSON::ParserError
    map_access_token(times + 1) if times < 5
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

  def map_picker_center(resource, marker)
    return marker if marker&.lat && marker&.lon

    Placement.find_by_path(resource.persisted_edge&.path, %w[custom country]) ||
      Place.find_or_fetch_country('nl')
  end

  def map_picker_props(resource) # rubocop:disable Metrics/AbcSize
    marker = resource.custom_placement
    center = map_picker_center(resource, marker)
    {
      accessToken: map_access_token,
      icon: {
        iconUrl: image_url('marker-icon.png'),
        iconAnchor: [13, 44]
      },
      centerLat: center.lat,
      centerLon: center.lon,
      initialZoom: center.zoom_level,
      markerId: marker&.id,
      markerLat: marker&.lat,
      markerLon: marker&.lon,
      markerType: 'custom',
      required: resource.is_a?(Motion) && resource.parent.try(:require_location?),
      resourceType: resource.class_name.singularize
    }
  end

  def map_question_props(resource) # rubocop:disable Metrics/AbcSize
    popup_link = new_iri(resource, :motions)
    popup_link.query = 'lat={lat}&lon={lon}&zoom_level={zoom}'.encode(Encoding::UTF_8)
    map_viewer_props(
      Placement
        .custom
        .joins('INNER JOIN edges ON edges.uuid = placements.placeable_id AND placements.placeable_type = \'Edge\'')
        .where(edges: {id: @all_motion_edges.pluck(:id)})
        .includes(:place, placeable: {parent: :shortname})
        .map { |placement| map_marker_props(placement) },
      popup: {
        header: {
          href: popup_link.to_s,
          fa: 'lightbulb-o',
          text: t('add_type', type: motion_type)
        }
      },
      center_lat: resource.custom_placement&.lat,
      center_lon: resource.custom_placement&.lon,
      zoom: resource.custom_placement&.zoom_level
    )
  end

  def map_resource_props(resource)
    placement = resource.custom_placement
    map_viewer_props(map_marker_props(placement), zoom: placement.zoom_level)
  end

  def map_viewer_props(markers, opts = {}) # rubocop:disable Metrics/AbcSize
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
