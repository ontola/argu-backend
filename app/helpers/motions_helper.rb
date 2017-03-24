# frozen_string_literal: true
include ActsAsTaggableOn::TagsHelper

module MotionsHelper
  def actor_props(actor)
    return nil unless actor
    {
      actor_type: actor.profileable.class.name,
      shortname: actor.url,
      display_name: actor.display_name,
      name: actor.name,
      profile_photo: actor.default_profile_photo&.url,
      url: dual_profile_url(actor)
    }
  end

  def motion_vote_props(actor, motion, vote, opts = {})
    arguments = policy_scope(motion.arguments).collect do |argument|
      {
        id: argument.id,
        displayName: argument.display_name,
        key: argument.identifier,
        side: argument.key.to_s
      }
    end
    localized_react_component({
      actor: actor_props(actor),
      arguments: arguments,
      buttonsType: opts.fetch(:buttons_type, 'big'),
      currentVote: vote.try(:for) || 'abstain',
      currentExplanation: {explanation: vote&.explanation, explained_at: vote&.explained_at},
      closed: motion.edge.has_expired_ancestors?,
      distribution: motion_vote_counts(motion),
      objectId: motion.id,
      objectType: 'motion',
      percent: {
        pro: motion.default_vote_event.votes_pro_percentage,
        neutral: motion.default_vote_event.votes_neutral_percentage,
        con: motion.default_vote_event.votes_con_percentage
      },
      selectedArguments: vote&.argument_ids,
      total_votes: motion.default_vote_event.total_vote_count,
      vote_url: motion_votes_path(motion)
    }.merge(opts))
  end

  def motion_vote_counts(motion, opts = {})
    opts.merge(
      pro: motion.default_vote_event.children_count(:votes_pro),
      neutral: motion.default_vote_event.children_count(:votes_neutral),
      con: motion.default_vote_event.children_count(:votes_con)
    )
  end

  def user_vote_for(motion)
    @user_votes&.find { |v| v.voteable_id == motion.id && v.voteable_type == 'Motion' }
  end
end
