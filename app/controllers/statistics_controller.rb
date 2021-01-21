# frozen_string_literal: true

class StatisticsController < ParentableController
  include StatisticsHelper

  private

  def authorize_action
    authorize parent_resource!, :statistics?
  end

  def observation_dimensions
    @observation_dimensions ||= {NS::SCHEMA[:about] => parent_resource.iri}
  end

  def observation_measures
    @observation_measures ||= build_observation_measures(parent_resource)
  end

  def requested_resource # rubocop:disable Metrics/MethodLength
    @requested_resource ||=
      DataCube::Set.new(
        dimensions: observation_dimensions.keys,
        iri: RDF::URI(request.original_url),
        label: I18n.t('statistics.header'),
        measures: observation_measures.keys,
        observations: [
          dimensions: observation_dimensions,
          measures: observation_measures
        ],
        parent: parent_resource
      )
  end

  def resource_by_id_parent; end

  def show_includes
    [:observations, data_structure: %i[measures dimensions]]
  end
end
