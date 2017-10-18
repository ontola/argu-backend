# frozen_string_literal: true

class StatisticsController < EdgeTreeController
  include NestedResourceHelper
  alias authenticated_edge parent_resource
  helper_method :contribution_keys

  def show
    return unless stale?(last_modified: authenticated_edge.self_and_descendants.maximum(:updated_at))
    counts = descendants.group(:owner_type).count
    @statistics = {
      users: descendants.select(:user_id).distinct.count,
      votes: descendants
               .joins(:parent)
               .where(owner_type: 'Vote', parents_edges: {owner_type: 'VoteEvent'})
               .count,
      questions: counts['Question'] || 0,
      motions: counts['Motion'] || 0,
      opinions: descendants
                  .where(owner_type: 'Vote')
                  .joins('INNER JOIN votes ON votes.id=edges.owner_id')
                  .where('explained_at IS NOT NULL AND explanation != \'\'')
                  .count,
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

  def authorize_action
    authorize parent_resource, :statistics?
  end

  def contribution_keys
    %i[motions opinions comments arguments]
  end

  def descendants
    authenticated_edge.descendants.published.untrashed
  end

  def resource_by_id
    parent_resource.owner
  end
end
