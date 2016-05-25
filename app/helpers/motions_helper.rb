include ActsAsTaggableOn::TagsHelper
module MotionsHelper
  def actor_props(actor)
    return nil unless actor
    {
      actor_type: actor.owner.class.name,
      shortname: actor.url,
      display_name: actor.display_name,
      name: actor.name,
      url: dual_profile_url(actor)
    }
  end

  def motion_combi_vote_props(actor, motion, vote)
    localized_react_component({
                                votes: ordered_votes(policy_scope(motion.votes))
                              }.merge(motion_vote_props(actor, motion, vote)))
    arguments = policy_scope(motion.arguments).collect do |argument|
      {
        id: argument.id,
        displayName: argument.display_name,
        key: argument.identifier,
        side: argument.key.to_s
      }
    end
  end

  def motion_partial_vote_props(actor, motion, vote, opts = {})
    localized_react_component({
                                votes: ordered_votes(policy_scope(motion.votes.where(voter: actor)))
                              }.merge(motion_vote_props(actor, motion, vote, opts)))
  end

  def motion_vote_props(actor, motion, vote, opts = {})
    localized_react_component opts.merge(
      objectType: 'motion',
      objectId: motion.id,
      currentVoteId: vote.try(:id),
      vote_url: motion_show_vote_path(motion),
      total_votes: motion.total_vote_count,
      buttons_type: opts.fetch(:buttons_type, 'big'),
      actor: actor_props(actor),
      distribution: motion_vote_counts(motion),
      percent: {
        pro: motion.votes_pro_percentage,
        neutral: motion.votes_neutral_percentage,
        con: motion.votes_con_percentage
      }
    )
  end

  def motion_vote_counts(motion, opts = {})
    opts.merge(
      pro: motion.votes_pro_count,
      neutral: motion.votes_neutral_count,
      con: motion.votes_con_count
    )
  end

  def ordered_votes(scope)
    votes = ActiveModelSerializers::SerializableResource.new(scope, include: '**').as_json
    ordered_votes = {}
    votes[:data].each do |v|
      ordered_votes[v[:id]] = {id: v[:id], type: v[:type]}
                                .merge(v[:attributes])
                                .merge(v[:relationships])
    end
    ordered_votes
  end

  def user_vote_for(motion)
    @user_votes && @user_votes.find { |v| v.voteable == motion }
  end
end
