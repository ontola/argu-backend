# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feed, type: :model do
  define_spec_objects
  subject { argu_feed }

  let(:argu_feed) { Feed.new(parent: argu, relevant_only: relevant_only, root_id: argu.uuid) }
  let(:scoped_activities) do
    ActivityPolicy::Scope.new(
      UserContext.new(doorkeeper_scopes: {}, profile: user.profile, user: user),
      subject.activities
    ).resolve
  end
  let(:hidden_votes) { Vote.joins(:creator).where(profiles: {are_votes_public: false}) }
  let(:granted_activities) do
    Activity
      .joins(:trackable)
      .where("edges.path <@ '#{granted_resource.path}' AND key ~ '*.create|publish|forwarded'")
      .where(edges: {is_published: true})
  end

  RSpec.shared_examples_for 'scope' do
    let(:activities_count) { granted_activities.count - hidden_votes.count }
    let(:relevant_activities_count) { granted_activities.where('key IN (?)', Feed::RELEVANT_KEYS).count }

    context 'relevant_only' do
      let(:relevant_only) { true }

      it 'applies' do
        expect(scoped_activities.count).to eq(relevant_activities_count)
      end
    end

    context 'all activities' do
      let(:relevant_only) { false }

      it 'applies' do
        expect(scoped_activities.count).to eq(activities_count)
      end
    end
  end

  context 'user' do
    let(:user) { create(:user) }
    let(:granted_resource) { freetown }

    it_behaves_like 'scope'
  end

  context 'user with disabled comments' do
    let(:user) { create(:user) }
    let(:granted_resource) { freetown }
    let(:granted_activities) do
      Activity
        .joins(:trackable)
        .where("edges.path <@ '#{granted_resource.path}' AND key ~ '*.create|publish|forwarded'")
        .where(edges: {is_published: true})
        .where("edges.owner_type != 'Comment'")
    end
    before do
      grant_set = GrantSet.participator.clone('adam_west_set', argu)
      grant_set.grant_sets_permitted_actions.joins(:permitted_action).where('title LIKE ?', 'comment_%').destroy_all
      freetown.update!(public_grant: 'adam_west_set')
    end

    it_behaves_like 'scope'
  end

  context 'freetown moderator' do
    let(:user) { create_moderator(freetown) }
    let(:granted_resource) { freetown }
    it_behaves_like 'scope'
  end

  context 'argu moderator' do
    let(:user) { create_moderator(argu) }
    let(:granted_resource) { argu }
    it_behaves_like 'scope'
  end
end
