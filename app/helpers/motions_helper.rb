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

  def motion_combi_vote_props(actor, motion, vote)
    groups = policy_scope(motion.forum.page.groups.discussion).collect do |group|
      {
          id: group.id,
          name: group.name,
          name_singular: group.name_singular,
          icon: group.icon,
          responses_left: group.responses_left(motion, actor),
          actor_group_responses: group.responses_for(motion, actor)
      }
    end
    localized_react_component({
        groups: groups
    }.merge(motion_vote_props(actor, motion, vote)))
  end

  def motion_vote_props(actor, motion, vote, opts = {})
    localized_react_component({
      objectType: 'motion',
      objectId: motion.id,
      currentVote: vote.try(:for) || 'abstain',
      vote_url: motion_show_vote_path(motion),
      total_votes: motion.total_vote_count,
      buttonsType: opts.fetch(:buttons_type, 'big'),
      actor: actor_props(actor),
      distribution: motion_vote_counts(motion),
      percent: {
        pro: motion.votes_pro_percentage,
        neutral: motion.votes_neutral_percentage,
        con: motion.votes_con_percentage
      }
    }.merge(opts))
  end

  def motion_vote_counts(motion, opts = {})
    opts.merge(
      pro: motion.votes_pro_count,
      neutral: motion.votes_neutral_count,
      con: motion.votes_con_count
    )
  end

  def user_vote_for(motion)
    @user_votes && @user_votes.find { |v| v.voteable == motion }
  end
end
