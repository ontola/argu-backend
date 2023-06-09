# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feed, type: :model do
  define_spec_objects
  subject { argu_feed }

  let(:argu_feed) { described_class.new(parent: argu) }
  let(:user) { create(:user) }
  let(:scoped_activities) do
    ActivityPolicy::Scope.new(
      UserContext.new(profile: user.profile, user: user),
      subject.activities
    ).resolve
  end
  let(:hidden_votes) { Vote.joins(:publisher).where(users: {show_feed: false}) }
  let(:ungranted_activities) do
    ActsAsTenant.without_tenant do
      Activity
        .all
        .reject do |a|
        granted_paths.any? { |p| a.trackable.path == p || a.trackable.path.include?("#{p}.") }
      end
    end
  end
  let(:unpublished_branch_activities) do
    Activity
      .all
      .select do |a|
      !a.trackable.is_published? ||
        a.trackable.ancestors.any? { |trackable| !trackable.is_published || trackable.is_trashed? }
    end
  end
  let(:hidden_vote_activities) do
    Activity.all.select { |a| hidden_votes.include?(a.trackable) }
  end
  let(:granted_paths) { [freetown.path] }

  before do
    ActsAsTenant.current_tenant = argu
  end

  RSpec.shared_examples_for 'scope' do
    context 'all activities' do
      it 'also contains irrelevant activities' do
        expect(scoped_activities).not_to be_empty
      end

      it 'does not contain items with unpublished ancestors' do
        expect(unpublished_branch_activities).to be_present
        expect(scoped_activities & unpublished_branch_activities).to be_empty
      end

      it 'does not include hidden votes' do
        expect(hidden_votes).to be_present
        expect(scoped_activities & hidden_vote_activities).to be_empty
      end

      it 'does not include ungranted_activities' do
        expect(granted_paths).to(
          be_all { |path| scoped_activities.any? { |a| a.trackable.path.include?("#{path}.") } }
        )
        expect(ungranted_activities).to be_present
        expect(scoped_activities & ungranted_activities).to be_empty
      end
    end
  end

  context 'user' do
    it_behaves_like 'scope'
  end

  context 'freetown moderator' do
    let(:user) { create_moderator(freetown) }

    it_behaves_like 'scope'
  end

  context 'argu moderator' do
    let(:user) { create_moderator(argu) }
    let(:granted_paths) { [freetown.path, holland.path] }
    let!(:ungranted_motion) { create(:motion, parent: create(:forum, url: 'other_forum', parent: create_page)) }

    it_behaves_like 'scope'
  end

  context 'user with disabled comments' do
    let(:comment_activities) do
      Activity.all.select { |a| a.trackable.is_a?(Comment) }
    end

    before do
      grant_set = GrantSet.participator.clone('adam_west_set', argu)
      grant_set.grant_sets_permitted_actions.joins(:permitted_action).where('title LIKE ?', 'comment_%').destroy_all
      ActsAsTenant.with_tenant(argu) do
        freetown.initial_public_grant = 'adam_west_set'
        freetown.send(:create_default_grant)
      end
    end

    it 'does not include comment activities' do
      expect(comment_activities).to be_present
      expect(scoped_activities & comment_activities).to be_empty
    end
  end
end
