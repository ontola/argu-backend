# frozen_string_literal: true
module VotesHelper
  def preload_user_votes(voteable_ids)
    @user_votes = Vote.where(voteable_id: voteable_ids,
                             voteable_type: 'Motion',
                             creator: current_profile).eager_load!
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
    model.votes.find_by(creator: profile)
  end
end
