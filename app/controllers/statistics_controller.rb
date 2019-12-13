# frozen_string_literal: true

class StatisticsController < ParentableController
  before_action { fresh_when(last_modified: parent_resource.self_and_descendants.maximum(:updated_at)) }

  helper_method :contribution_keys
  helper_method :additional_stats

  private

  def additional_stats
    case parent_resource
    when Forum
      return [] unless current_user.is_staff?
      [
        {
          title: t('forums.statistics.cities.title'),
          description: t('forums.statistics.cities.info'),
          stats: city_count(parent_resource)
        }
      ]
    else
      []
    end
  end

  def authorize_action
    authorize parent_resource!, :statistics?
  end

  def city_count(forum) # rubocop:disable Metrics/AbcSize
    cities = Hash.new(0)
    User
      .joins(:follows)
      .where(follows: {followable: forum})
      .includes(home_placement: :place)
      .map { |u| u.home_placement&.place&.address.try(:[], 'city') || t('forums.statistics.cities.unknown') }
      .each { |v| cities.store(v, cities[v] + 1) }
    cities.sort { |x, y| y[1] <=> x[1] }
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

  def observation_measures # rubocop:disable Metrics/AbcSize
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

  def resource_by_id
    @resource_by_id ||=
      DataCube::Set.new(
        dimensions: observation_dimensions.keys,
        iri: RDF::URI(request.original_url),
        label: t('statistics.header'),
        measures: observation_measures.keys,
        observations: [
          dimensions: observation_dimensions,
          measures: observation_measures
        ]
      )
  end

  def resource_by_id_parent; end

  def show_includes
    [:observations, data_structure: %i[measures dimensions]]
  end

  def show_success_html
    render 'show', locals: {resource: authenticated_resource}
  end
end
