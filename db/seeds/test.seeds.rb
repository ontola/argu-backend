# frozen_string_literal: true

require 'factory_seeder'

load(Dir[Rails.root.join('db/seeds/doorkeeper_apps.seeds.rb')][0])

Apartment::Tenant.switch('public') do
  Tenant.delete_all
  Tenant.create_system_users unless User.any?
end

Apartment::Tenant.drop('argu') if ApplicationRecord.connection.schema_exists?('argu')
Tenant.setup_schema('argu', "#{Rails.application.config.host_name}/first_page", 'first_page')

Apartment::Tenant.switch!('argu')
ActsAsTenant.current_tenant.update(url: 'first_page')
ActsAsTenant.current_tenant = nil

staff = FactorySeeder.create(
  :user,
  display_name: 'argu_owner',
  email: 'staff@example.com'
)
staff_group = Group.find(Group::STAFF_ID)
staff_membership =
  CreateGroupMembership.new(
    staff_group,
    attributes: {member: staff.profile},
    options: {user_context: UserContext.new(user: staff, profile: staff.profile)}
  ).resource
staff_membership.save(validate: false)

FactorySeeder.create(
  :unconfirmed_user,
  email: 'unconfirmed@example.com'
)

page = FactorySeeder.create(
  :page,
  active_branch: true,
  profile: Profile.new,
  id: 0,
  name: 'Argu page',
  url: 'argu',
  iri_prefix: 'argu.localtest/argu',
  publisher: staff,
  creator: staff.profile,
  is_published: true,
  locale: 'en-GB',
  root_id: 'deadbeef-bfc5-4e68-993f-430037bd5bd3',
  uuid: 'deadbeef-bfc5-4e68-993f-430037bd5bd3'
)

freetown = ActsAsTenant.with_tenant(page) do
  FactorySeeder.create_forum(
    :with_follower,
    url: 'freetown',
    name: 'Freetown',
    parent: page,
    initial_public_grant: 'initiator'
  )
end
page.update(primary_container_node_id: freetown.uuid)
holland = ActsAsTenant.with_tenant(page) do
  FactorySeeder.create_forum(
    :populated_forum,
    parent: page,
    url: 'holland',
    name: 'Holland',
    discoverable: false
  )
end

other_page = FactorySeeder.create(
  :page,
  active_branch: true,
  publisher: staff,
  creator: staff.profile,
  is_published: true,
  name: 'Other page',
  primary_color: '#800000',
  url: 'other_page',
  locale: 'en-GB',
  iri_prefix: 'argu.localtest/other_page'
)
ActsAsTenant.with_tenant(other_page) do
  FactorySeeder.create_forum(
    parent: other_page,
    url: 'other_page_forum',
    name: 'Other page forum',
    initial_public_grant: 'participator'
  )
end
ActsAsTenant.with_tenant(other_page) do
  FactorySeeder.create_forum(
    parent: other_page,
    url: 'other_page_forum2',
    name: 'Other page forum2',
    initial_public_grant: 'spectator'
  )
end

ActsAsTenant.with_tenant(page) do # rubocop:disable  Metrics/BlockLength
  members_group =
    FactorySeeder
      .create(:group, id: 111, name: 'Members', name_singular: 'Member', parent: holland.root)
  group_member = FactorySeeder.create(:user, email: 'member@example.com')
  FactorySeeder.create(:group_membership, parent: members_group, member: group_member.profile)

  FactorySeeder.create(:grant, edge: holland, group: members_group, grant_set: GrantSet.initiator)
  moderators_group =
    FactorySeeder
      .create(:group, id: 222, name: 'Moderators', name_singular: 'Moderator', parent: holland.root)
  FactorySeeder.create(:grant, edge: holland, group: moderators_group, grant_set: GrantSet.moderator)

  placeholder =
    FactorySeeder.create(:motion, creator: Profile.community, publisher: User.community, parent: freetown)
  FactorySeeder.create(:pro_argument, parent: placeholder)
  FactorySeeder.create(:comment, parent: placeholder)
  placeholder_vote_event = placeholder.default_vote_event
  FactorySeeder.create(:vote, parent: placeholder_vote_event)

  forum_motion = FactorySeeder.create_with_name(:motion, :freetown_motion, parent: freetown)
  FactorySeeder.create(:pro_argument, parent: forum_motion)
  question = FactorySeeder.create_with_name(:question, :freetown_question, parent: freetown)
  motion = FactorySeeder.create_with_name(:motion, :question_motion, parent: question)
  FactorySeeder.create(:group_membership, parent: FactorySeeder.create(:group, parent: page, name: 'custom'))
  FactorySeeder.create(
    :decision,
    parent: motion,
    state: 'approved'
  )
  vote_event = motion.default_vote_event
  FactorySeeder.create(:vote, parent: vote_event)

  profile_hidden_votes = FactorySeeder.create(:user, show_feed: false).profile
  FactorySeeder
    .create(:vote, parent: vote_event, creator: profile_hidden_votes, publisher: profile_hidden_votes.profileable)

  argument = FactorySeeder.create_with_name(:pro_argument, :motion_argument, parent: motion)
  FactorySeeder.create(:vote, parent: argument)
  comment = FactorySeeder.create_with_name(:comment, :argument_comment, parent: argument)
  FactorySeeder.create_with_name(
    :comment,
    :nested_argument_comment,
    parent: argument,
    parent_comment_id: comment.uuid
  )
  FactorySeeder.create(:blog_post, parent: motion)
  blog_post =
    FactorySeeder.create(:blog_post, parent: question)
  FactorySeeder.create(:comment, parent: blog_post)
  FactorySeeder.create(:comment, parent: motion)

  hidden_question = FactorySeeder.create_with_name(:question, :hidden_question, parent: holland)
  FactorySeeder.create(:motion, parent: hidden_question)

  trashed_question =
    FactorySeeder.create_with_name(
      :question,
      :trashed_question,
      parent: freetown
    )
  TrashService.new(
    trashed_question,
    options: {user_context: UserContext.new(profile: trashed_question.creator, user: trashed_question.publisher)}
  ).commit
  trashed_motion =
    FactorySeeder.create_with_name(
      :motion,
      :trashed_motion,
      parent: trashed_question
    )
  FactorySeeder.create(:pro_argument, parent: trashed_motion)

  unpublished_question =
    FactorySeeder.create_with_name(
      :question,
      :unpublished_question,
      parent: freetown,
      argu_publication_attributes: {draft: true}
    )
  unpublished_motion =
    FactorySeeder.create_with_name(
      :motion,
      :unpublished_motion,
      parent: unpublished_question
    )
  FactorySeeder.create(:pro_argument, parent: unpublished_motion)

  expired_question =
    FactorySeeder.create_with_name(
      :question,
      :expired_question,
      parent: freetown,
      expires_at: Time.current
    )
  expired_motion =
    FactorySeeder.create_with_name(
      :motion,
      :expired_motion,
      parent: expired_question
    )
  FactorySeeder.create(:pro_argument, parent: expired_motion)
  FactorySeeder.create(:topic, parent: freetown)

  FactorySeeder.create(:export, parent: freetown, user: FactorySeeder.create(:user))
  FactorySeeder.create(:export, parent: motion, user: FactorySeeder.create(:user))

  budget = FactorySeeder.create_with_name(:budget_shop, :budget_shop, parent: freetown, budget_max: 1000)
  FactorySeeder.create_with_shortname(:offer, :offer_600, parent: budget, product_id: motion.uuid, price: 600)
  FactorySeeder.create_with_shortname(:offer, :offer_300, parent: budget, product_id: expired_motion.uuid, price: 300)
  FactorySeeder.create_with_shortname(:offer, :offer_200, parent: budget, product_id: forum_motion.uuid, price: 200)
  batch = FactorySeeder.create(:coupon_batch, parent: budget)
  batch.update(coupons: %w[COUPON1 COUPON1])

  survey_iri = 'https://arthurdingemans.typeform.com/to/E6zdDk?__dangerous-disable-submissions'
  open_survey = FactorySeeder.create_with_name(
    :survey,
    :typeform_survey,
    parent: freetown,
    external_iri: survey_iri
  )
  batch = FactorySeeder.create(:coupon_batch, parent: open_survey)
  batch.update(coupons: %w[COUPON1 COUPON1])

  coupon_survey = FactorySeeder.create_with_name(
    :survey,
    :reward_survey,
    parent: freetown,
    external_iri: survey_iri,
    coupon_required: true
  )
  batch = FactorySeeder.create(:coupon_batch, parent: coupon_survey)
  batch.update(coupons: %w[COUPON1 COUPON1])
end

FactorySeeder.create(
  :two_fa_user,
  email: '2fa@example.com'
)
