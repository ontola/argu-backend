# frozen_string_literal: true

module VotesHelper
  def icon_for_side(side)
    case side.to_s
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
      Edge.where_owner('Vote', creator: profile, root_id: model.root_id).find_by(parent: model, primary: true)
    end
  end

  def vote_iri(model, vote)
    RDF::DynamicURI(path_with_hostname(vote_iri_path(model, vote)))
  end

  def vote_iri_path(model, vote)
    return collection_iri_path(model, :votes, for: :pro) if vote.blank?

    if vote.try(:persisted?)
      vote.iri_path
    else
      expand_uri_template(:vote_iri, parent_iri: split_iri_segments(model.iri_path), for: :pro)
    end
  end
end
