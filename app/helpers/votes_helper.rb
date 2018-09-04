# frozen_string_literal: true

module VotesHelper
  def preload_user_votes(voteable_ids)
    @user_votes = if current_user.confirmed?
                    Edge
                      .where_owner('Vote', creator: current_profile, primary: true)
                      .where(parent_id: voteable_ids)
                      .includes(:creator)
                      .eager_load!
                  else
                    Edge.where_owner('Vote', primary: true, creator: current_profile)
                  end
  end

  def toggle_vote_link(model, vote)
    classes = 'upvote btn-subtle btn--mini tooltip tooltip--left'
    data = {
      'voted-on': vote.present?
    }
    if policy(model).create_child?(:votes)
      toggle_vote_link_enabled(model, vote, classes, data) do
        yield
      end
    else
      toggle_vote_link_disabled(model, vote, classes, data) do
        yield
      end
    end
  end

  def toggle_vote_link_disabled(model, vote, classes, data)
    data[:title] = if policy(vote || Vote.new(parent: model)).has_expired_ancestors?
                     t('votes.disabled.expired')
                   else
                     t('votes.disabled.unauthorized')
                   end
    content_tag(:span, class: classes, data: data) do
      yield
    end
  end

  def toggle_vote_link_enabled(model, vote, classes, data)
    data[:remote] = true
    data[:method] = vote_method(vote)
    data[:title] = vote.present? ? t('tooltips.argument.vote_up_undo') : t('tooltips.argument.vote_up')
    link_to vote_iri_path(model, vote), rel: :nofollow, class: classes, data: data do
      yield
    end
  end

  def icon_for_side(side)
    case side
    when 'pro', 'yes'
      'thumbs-up'
    when 'neutral', 'other'
      'pause'
    when 'con', 'no'
      'thumbs-down'
    end
  end

  def upvote_for(model, profile)
    if profile.confirmed?
      model.votes.detect { |vote| vote.creator_id == profile.id }
    else
      Edge.where_owner('Vote', creator: profile, root_id: model.root_id).find_by(parent: model)
    end
  end

  def vote_event_ids_from_activities(activities)
    activities
      .joins(trackable: :children)
      .where(edges: {owner_type: 'Motion'})
      .where(children_edges: {owner_type: 'VoteEvent'})
      .pluck('children_edges.id')
  end

  def vote_iri(model, vote)
    RDF::DynamicURI(path_with_hostname(vote_iri_path(model, vote)))
  end

  def vote_iri_path(model, vote)
    return collection_iri_path(model, :votes, for: :pro) if vote.blank?
    if vote.try(:persisted?)
      vote.iri_path
    else
      expand_uri_template(:vote_iri, parent_iri: model.iri_path, for: :pro)
    end
  end

  def vote_method(vote)
    vote.present? ? :delete : :post
  end
end
