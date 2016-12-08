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
      url: dual_profile_url(actor)
    }
  end

  def motion_vote_props(actor, motion, vote, opts = {})
    localized_react_component({
      actor: actor_props(actor),
      buttonsType: opts.fetch(:buttons_type, 'big'),
      currentVote: vote.try(:for) || 'abstain',
      closed: motion.closed?,
      distribution: motion_vote_counts(motion),
      objectId: motion.id,
      objectType: 'motion',
      percent: {
        pro: motion.votes_pro_percentage,
        neutral: motion.votes_neutral_percentage,
        con: motion.votes_con_percentage
      },
      total_votes: motion.total_vote_count,
      vote_url: motion_show_vote_path(motion)
    }.merge(opts))
  end

  def motion_vote_counts(motion, opts = {})
    opts.merge(
      pro: motion.children_count(:votes_pro),
      neutral: motion.children_count(:votes_neutral),
      con: motion.children_count(:votes_con)
    )
  end

  def user_vote_for(motion)
    @user_votes&.find { |v| v.voteable == motion }
  end
end
