# frozen_string_literal: true

module StatisticsHelper
  def contribution_keys
    [NS.argu[:motionsCount], NS.argu[:commentsCount], NS.argu[:argumentsCount]]
  end

  def descendants(resource)
    resource.descendants.published.untrashed
  end

  def build_observation_measures(resource) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    descendants = resource.descendants.published.untrashed

    counts = descendants.group(:owner_type).count
    votes = descendants.joins(:parent).where(owner_type: 'Vote', parents_edges: {owner_type: 'VoteEvent'})

    observation_measures = {
      NS.argu[:usersCount] => descendants.select(:publisher_id).distinct.count,
      NS.argu[:votesCount] => votes.where(confirmed: true).count,
      NS.argu[:unconfirmedVotesCount] => votes.where(confirmed: false).count,
      NS.argu[:questionsCount] => counts['Question'] || 0,
      NS.argu[:motionsCount] => counts['Motion'] || 0,
      NS.argu[:commentsCount] => counts['Comment'] || 0,
      NS.argu[:argumentsCount] => [counts['Argument'], counts['ProArgument'], counts['ConArgument']].compact.sum
    }
    observation_measures[NS.argu[:contributionsCount]] =
      contribution_keys.reduce(0) { |sum, key| sum + observation_measures[key] }
    observation_measures
  end
end
