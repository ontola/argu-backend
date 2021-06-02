# frozen_string_literal: true

class StatisticsController < ParentableController
  include StatisticsHelper

  private

  def authorize_action
    raise(ActiveRecord::RecordNotFound) unless parent_resource!.enhanced_with?(Statable)

    authorize parent_resource, :statistics?
  end

  def observation_dimensions
    @observation_dimensions ||= {NS::SCHEMA[:about] => parent_from_params.iri}
  end

  def observation_measures
    @observation_measures ||= build_observation_measures(parent_from_params)
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
        parent: parent_from_params
      )
  end

  def requested_resource_parent; end
end
