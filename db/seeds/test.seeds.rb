# frozen_string_literal: true

require 'factory_seeder'

load(Dir[Rails.root.join('db', 'seeds', 'grant_sets.seeds.rb')][0])

FactorySeeder.create(
  :user,
  id: User::COMMUNITY_ID,
  shortname: FactorySeeder.build(:shortname, shortname: 'community'),
  email: 'community@argu.co',
  first_name: nil,
  last_name: nil,
  profile: FactorySeeder.build(:profile, id: Profile::COMMUNITY_ID)
)
FactorySeeder.create(
  :user,
  id: User::ANONYMOUS_ID,
  shortname: FactorySeeder.build(:shortname, shortname: 'anonymous'),
  email: 'anonymous@argu.co',
  first_name: nil,
  last_name: nil,
  profile: FactorySeeder.build(:profile, id: Profile::ANONYMOUS_ID)
)

staff = FactorySeeder.create(
  :user,
  shortname: FactorySeeder.build(:shortname, shortname: 'argu_owner'),
  email: 'staff@example.com'
)
page = FactorySeeder.create(
  :page,
  id: 0,
  last_accepted: Time.current,
  profile: FactorySeeder.build(:profile, name: 'Argu page'),
  owner: staff.profile,
  url: 'argu',
  user: staff,
  is_published: true
)

public_group = FactorySeeder.create(
  :group,
  id: Group::PUBLIC_ID,
  parent: Page.find(0).edge,
  name: 'Public group',
  name_singular: 'User'
)
public_membership =
  CreateGroupMembership.new(
    public_group,
    attributes: {member: Profile.community},
    options: {publisher: User.community, creator: Profile.community}
  ).resource
public_membership.save(validate: false)
FactorySeeder.create(:group_membership, parent: public_group, member: staff.profile)

staff_group = FactorySeeder.create(
  :group,
  id: Group::STAFF_ID,
  parent: Page.find(0).edge,
  name: 'Staff group',
  name_singular: 'Staff'
)
staff_membership =
  CreateGroupMembership.new(
    staff_group,
    attributes: {member: staff.profile},
    options: {publisher: staff, creator: staff.profile}
  ).resource
staff_membership.save(validate: false)

page.send(:create_staff_grant)

Doorkeeper::Application.create!(
  id: Doorkeeper::Application::ARGU_ID,
  name: 'Argu',
  owner: Profile.community,
  redirect_uri: 'https://argu.localdev/',
  scopes: 'guest user',
  secret: 'secret',
  uid: 'uid'
)

token = Doorkeeper::AccessToken.find_or_create_for(
  Doorkeeper::Application.argu,
  User::COMMUNITY_ID,
  'service',
  Doorkeeper.configuration.access_token_expires_in,
  false
)
token.update(
  token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOiIyMDE4LTAzLTE2VDA5OjM0OjA3LjI0NDQ5WiIsInVzZXIiOnsidHlwZSI6InV'\
         'zZXIiLCJAaWQiOiJodHRwczovL2FyZ3UuY28vdS9jb21tdW5pdHkiLCJpZCI6MCwiZW1haWwiOiJjb21tdW5pdHlAYXJndS5jbyJ9fQ.YGpt'\
         '8CSkxtO7ZNgZtUns5-NO5l1yNoHDStSafqo9e2zNbPJD38QZYHbcbr4-bdOnl3O455b5g7wtjBjvvV7ADQ'
)

Doorkeeper::Application.create!(
  id: Doorkeeper::Application::AFE_ID,
  name: 'Argu Front End',
  owner: Profile.community,
  redirect_uri: 'https://argu.localdev/',
  scopes: 'guest user afe',
  secret: 'afe_secret',
  uid: 'afe_uid'
)

afe_token = Doorkeeper::AccessToken.find_or_create_for(
  Doorkeeper::Application.argu_front_end,
  User::COMMUNITY_ID,
  'service',
  Doorkeeper.configuration.access_token_expires_in,
  false
)
afe_token.update(
  token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOiIyMDE4LTAzLTE2VDA5OjM0OjA3LjI0NDQ5WiIsInVzZXIiOnsidHlwZSI6InV'\
         'zZXIiLCJAaWQiOiJodHRwczovL2FyZ3UuY28vdS9jb21tdW5pdHkiLCJpZCI6MSwiZW1haWwiOiJjb21tdW5pdHlAYXJndS5jbyJ9fQ.r3Lp'\
         '7TDGmCCdV5nlXWgjvCWmvEXYm4G7rjWmfoturzoNv73P9lyZN0Snyc6Tml_ZMMJHkm0kiFrJWEX1XdhZZg'
)

Doorkeeper::Application.create!(
  id: Doorkeeper::Application::SERVICE_ID,
  name: 'Argu Service',
  owner: Profile.community,
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  scopes: 'service worker export',
  secret: 'service_secret',
  uid: 'service_uid'
)

freetown = FactorySeeder.create_forum(
  :with_follower,
  url: 'freetown',
  name: 'Freetown',
  parent: page.edge,
  public_grant: 'participator'
)
holland = FactorySeeder.create_forum(
  :populated_forum,
  parent: page.edge,
  url: 'holland',
  name: 'Holland',
  discoverable: false,
  public_grant: 'none'
)

other_page = FactorySeeder.create(
  :page,
  user: staff,
  is_published: true,
  profile: FactorySeeder.build(:profile, name: 'Other page'),
  base_color: '#800000',
  url: 'other_page',
  edge_attributes: {user: staff, is_published: true}
)
other_page_forum = FactorySeeder.create_forum(
  parent: other_page.edge,
  url: 'other_page_forum',
  name: 'Other page forum',
  public_grant: 'participator'
)
FactorySeeder.create_forum(
  parent: other_page.edge,
  url: 'other_page_forum2',
  name: 'Other page forum2',
  public_grant: 'spectator'
)

members_group =
  FactorySeeder
    .create(:group, id: 111, name: 'Members', name_singular: 'Member', parent: holland.parent_model(:page).edge)
FactorySeeder.create(:grant, edge: holland.edge, group: members_group, grant_set: GrantSet.initiator)
moderators_group =
  FactorySeeder
    .create(:group, id: 222, name: 'Moderators', name_singular: 'Moderator', parent: holland.parent_model(:page).edge)
FactorySeeder.create(:grant, edge: holland.edge, group: moderators_group, grant_set: GrantSet.moderator)

linked_record = LinkedRecord.create_for_forum(page.url, freetown.url, SecureRandom.uuid)
FactorySeeder.create(:argument, parent: linked_record.edge)
FactorySeeder.create(:comment, parent: linked_record.edge)
linked_record_vote_event = linked_record.default_vote_event
FactorySeeder.create(:vote, parent: linked_record_vote_event.edge)
forum_motion = FactorySeeder.create(:motion, parent: freetown.edge)
FactorySeeder.create(:argument, parent: forum_motion.edge)
question = FactorySeeder.create(:question, parent: freetown.edge)
motion = FactorySeeder.create(:motion, parent: question.edge)
actor_membership =
  FactorySeeder.create(:group_membership, parent: FactorySeeder.create(:group, parent: page.edge))
FactorySeeder.create(
  :decision,
  parent: motion.edge,
  state: 'forwarded',
  forwarded_user: actor_membership.member.profileable,
  forwarded_group: actor_membership.group,
  happening_attributes: {happened_at: Time.current}
)
vote_event = motion.default_vote_event
FactorySeeder.create(:vote, parent: vote_event.edge)

profile_hidden_votes =
  FactorySeeder.create(:user, profile: FactorySeeder.build(:profile, are_votes_public: false)).profile
FactorySeeder
  .create(:vote, parent: vote_event.edge, creator: profile_hidden_votes, publisher: profile_hidden_votes.profileable)

argument = FactorySeeder.create(:argument, parent: motion.edge)
FactorySeeder.create(:vote, parent: argument.edge)
comment = FactorySeeder.create(:comment, parent: argument.edge)
FactorySeeder.create(:comment, parent: argument.edge, parent_id: comment.id)
FactorySeeder.create(:blog_post, parent: motion.edge, happening_attributes: {happened_at: Time.current})
blog_post =
  FactorySeeder.create(:blog_post, parent: question.edge, happening_attributes: {happened_at: Time.current})
FactorySeeder.create(:comment, parent: blog_post.edge)
FactorySeeder.create(:comment, parent: motion.edge)

hidden_question = FactorySeeder.create(:question, parent: holland.edge)
FactorySeeder.create(:motion, parent: hidden_question.edge)

trashed_motion =
  FactorySeeder.create(
    :motion,
    parent: question.edge,
    trashed_at: Time.current
  )
FactorySeeder.create(:argument, parent: trashed_motion.edge)

unpublished_motion =
  FactorySeeder.create(
    :motion,
    parent: question.edge,
    argu_publication_attributes: {draft: true}
  )
FactorySeeder.create(:argument, parent: unpublished_motion.edge)

FactorySeeder.create(:export, parent: freetown.edge, user: FactorySeeder.create(:user))
FactorySeeder.create(:export, parent: motion.edge, user: FactorySeeder.create(:user))

Setting.set('suggested_forums', [freetown.edge.uuid, other_page_forum.edge.uuid])
