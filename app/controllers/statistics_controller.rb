# frozen_string_literal: true

class StatisticsController < ParentableController
  before_action { fresh_when(last_modified: parent_resource.self_and_descendants.maximum(:updated_at)) }

  private

  def authorize_action
    authorize parent_resource!, :statistics?
  end

  def contribution_keys
    [NS::ARGU[:motionsCount], NS::ARGU[:commentsCount], NS::ARGU[:argumentsCount]]
  end

  def descendants
    parent_resource.descendants.published.untrashed
  end

  def observation_dimensions
    @observation_dimensions ||= {NS::SCHEMA[:about] => parent_resource.iri}
  end

  def observation_measures # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return @observation_measures if @observation_measures

    counts = descendants.group(:owner_type).count
    votes = descendants.joins(:parent).where(owner_type: 'Vote', parents_edges: {owner_type: 'VoteEvent'})
    @observation_measures = {
      NS::ARGU[:usersCount] => descendants.select(:publisher_id).distinct.count,
      NS::ARGU[:votesCount] => votes.where(confirmed: true).count,
      NS::ARGU[:unconfirmedVotesCount] => votes.where(confirmed: false).count,
      NS::ARGU[:questionsCount] => counts['Question'] || 0,
      NS::ARGU[:motionsCount] => counts['Motion'] || 0,
      NS::ARGU[:commentsCount] => counts['Comment'] || 0,
      NS::ARGU[:argumentsCount] => [counts['Argument'], counts['ProArgument'], counts['ConArgument']].compact.sum
    }
    @observation_measures[NS::ARGU[:contributionsCount]] =
      contribution_keys.reduce(0) { |sum, key| sum + @observation_measures[key] }
    @observation_measures
  end

  def resource_by_id # rubocop:disable Metrics/MethodLength
    @resource_by_id ||=
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
