# frozen_string_literal: true

module MotionsHelper
  def actor_props(actor)
    return nil unless actor
    {
      actor_type: actor.profileable.class.name,
      confirmed: actor.profileable.confirmed?,
      confirmationEmail: actor.profileable.email,
      shortname: actor.url,
      display_name: actor.display_name,
      name: actor.name,
      profile_photo: actor.default_profile_photo&.url,
      url: dual_profile_url(actor)
    }
  end

  def current_vote_props(vote)
    return {side: 'abstain'} if vote.nil?
    {
      id: vote.id,
      side: vote.for,
      comment: {iri: vote.comment&.iri, id: vote.comment&.id, body: vote.comment&.body || ''}
    }
  end

  def motion_vote_props(actor, motion, vote, opts = {})
    disabled_message = motion_vote_disabled_message(motion, vote)
    localized_react_component({
      actor: actor_props(actor),
      argumentUrl: collection_iri_path(motion, :arguments),
      arguments: motion_vote_arguments(motion),
      argumentsDisabled: !policy(motion).create_child?(:arguments),
      buttonsType: opts.fetch(:buttons_type, 'big'),
      commentsUrl: collection_iri_path(motion, :comments),
      currentVote: current_vote_props(vote),
      disabled: disabled_message.present?,
      disabledMessage: disabled_message,
      distribution: motion_vote_counts(motion),
      facebookUrl: omniauth_authorize_path(:user, :facebook, r: request.env['PATH_INFO']),
      forgotPassword: {
        href: new_user_password_path,
        text: t('forgot_password')
      },
      newArgumentButtons: policy(motion).create_child?(:arguments).present?,
      oauthTokenUrl: oauth_token_url,
      objectId: motion.id,
      objectType: 'motion',
      percent: motion.default_vote_event.votes_pro_percentages,
      policyPath: policy_path,
      userRegistrationUrl: user_registration_url(r: request.env['PATH_INFO']),
      selectedArguments: vote&.argument_ids || [],
      totalVotes: motion.default_vote_event.total_vote_count,
      vote_path: collection_iri_path(motion.default_vote_event, :votes)
    }.merge(opts))
  end

  def motion_vote_arguments(motion)
    motion.edge.arguments.active.includes(:parent, :owner).map do |argument|
      {
        id: argument.id,
        body: argument.description,
        commentCount: argument.children_count(:comments),
        displayName: argument.display_name,
        key: argument.identifier,
        side: argument.owner.key.to_s,
        url: argument.iri
      }
    end
  end

  def motion_vote_counts(motion, opts = {})
    opts.merge(
      pro: motion.default_vote_event.children_count(:votes_pro),
      neutral: motion.default_vote_event.children_count(:votes_neutral),
      con: motion.default_vote_event.children_count(:votes_con)
    )
  end

  def motion_vote_disabled_message(motion, vote)
    return if policy(motion.default_vote_event).create_child?(:votes)
    if policy(vote || Vote.new(edge: Edge.new(parent: motion.default_vote_event.edge))).has_expired_ancestors?
      t('votes.disabled.expired')
    else
      t('votes.disabled.unauthorized')
    end
  end

  def user_vote_for(motion)
    @user_votes&.find { |v| v.parent_id == motion.default_vote_event.edge.id }&.owner
  end
end
