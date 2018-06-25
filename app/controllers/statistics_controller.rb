# frozen_string_literal: true

class StatisticsController < ParentableController
  helper_method :contribution_keys
  helper_method :additional_stats

  def show
    return unless stale?(last_modified: authenticated_resource.self_and_descendants.maximum(:updated_at))
    counts = descendants.group(:owner_type).count
    votes = descendants.joins(:parent).where(owner_type: 'Vote', parents_edges: {owner_type: 'VoteEvent'})
    @statistics = {
      users: descendants.select(:publisher_id).distinct.count,
      votes: votes.where(confirmed: true).count,
      unconfirmed_votes: votes.where(confirmed: false).count,
      questions: counts['Question'] || 0,
      motions: counts['Motion'] || 0,
      comments: counts['Comment'] || 0,
      arguments: counts['Argument'] || 0
    }
    @statistics[:contributions] = contribution_keys.reduce(0) { |sum, key| sum + @statistics[key] }

    respond_to do |format|
      format.html do
        render 'show', locals: {resource: authenticated_resource}
      end
    end
  end

  private

  def additional_stats
    case resource_by_id
    when Forum
      return [] unless current_user.is_staff?
      [
        {
          title: t('forums.statistics.cities.title'),
          description: t('forums.statistics.cities.info'),
          stats: city_count(resource_by_id)
        }
      ]
    else
      []
    end
  end

  def authorize_action
    authorize resource_by_id!, :statistics?
  end

  def city_count(forum)
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
    %i[motions comments arguments]
  end

  def descendants
    authenticated_resource.descendants.published.untrashed
  end

  def resource_by_id
    parent_resource
  end
end
