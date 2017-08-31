# frozen_string_literal: true
module VotesHelper
  def preload_user_votes(voteable_ids)
    @user_votes = if current_user.confirmed?
                    Edge
                      .where_owner('Vote', creator: current_profile)
                      .where(parent_id: voteable_ids)
                      .eager_load!
                  else
                    Edge.where_owner('Vote', creator: current_profile)
                  end
  end

  def toggle_vote_link(model, vote)
    classes = 'upvote btn-subtle btn--mini tooltip tooltip--left'
    data = {
      'voted-on': vote.present?
    }
    if policy(model).create_child?(:votes)
      url = vote.try(:persisted?) ? vote_path(vote) : polymorphic_url([model, :votes], for: :pro)
      data[:remote] = true
      if vote.present?
        data[:method] = :delete
        data[:title] = t('tooltips.argument.vote_up_undo')
      else
        data[:method] = :post
        data[:title] = t('tooltips.argument.vote_up')
      end
      link_to url, rel: :nofollow, class: classes, data: data do
        yield
      end
    else
      data[:title] = if policy(vote || Vote.new(edge: Edge.new(parent: model.edge))).has_expired_ancestors?
                       t('votes.disabled.expired')
                     else
                       t('votes.disabled.unauthorized')
                     end
      content_tag(:span, class: classes, data: data) do
        yield
      end
    end
  end

  def icon_for_side(side)
    case side
    when 'pro'
      'thumbs-up'
    when 'neutral'
      'pause'
    when 'con'
      'thumbs-down'
    end
  end

  def upvote_for(model, profile)
    if profile.confirmed?
      model.edge.votes.detect { |vote| vote.creator_id == profile.id }
    else
      Edge.where_owner('Vote', creator: profile).find_by(parent: model.edge)&.owner
    end
  end

  def vote_event_ids_from_activities(activities)
    activities
      .where(trackable_type: 'Motion')
      .joins(trackable_edge: :children)
      .where(children_edges: {owner_type: 'VoteEvent'})
      .pluck('children_edges.id')
  end
end
