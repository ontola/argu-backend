# frozen_string_literal: true

require 'test_helper'

module RedisResource
  class ResourceTest < ActiveSupport::TestCase
    define_freetown
    let(:guest_user) { GuestUser.new(id: 'my_id') }
    let(:unconfirmed) { create(:unconfirmed_user) }
    let(:user) { create(:user) }
    let(:motion) { create(:motion, parent: freetown) }
    let(:confirmed_vote) { create(:vote, publisher: user, parent: motion.default_vote_event) }
    let(:vote) { create(:vote, publisher: user, parent: motion.default_vote_event) }
    let(:guest_vote) { create(:vote, publisher: guest_user, parent: motion.default_vote_event) }

    test 'find by key string' do
      redis_resource =
        RedisResource::Resource
          .find("temporary.guest_user.#{guest_user.id}.#{guest_vote.root_id}.vote.#{guest_vote.parent.id}")
      assert redis_resource.is_a?(RedisResource::Resource)
      assert redis_resource.resource.uuid == guest_vote.uuid
      assert_not redis_resource.resource.persisted?
    end

    test 'find by key object' do
      key = RedisResource::Key.new(
        user: guest_user,
        owner_type: 'vote',
        root_id: guest_vote.root_id,
        parent_id: motion.default_vote_event.id
      )
      redis_resource = RedisResource::Resource.find(key)
      assert redis_resource.is_a?(RedisResource::Resource)
      assert redis_resource.resource.uuid == guest_vote.uuid
      assert_not redis_resource.resource.persisted?
    end

    test 'save' do
      assert_difference('Vote.count' => 1, 'Argu::Redis.keys("temporary*").count' => 0) do
        create_vote(user)
      end
      assert_difference('Vote.count' => 1, 'Argu::Redis.keys("temporary*").count' => 0) do
        create_vote(unconfirmed)
      end
      assert_difference('Vote.count' => 0, 'Argu::Redis.keys("temporary*").count' => 1) do
        create_vote(guest_user)
      end
    end

    test 'destroy' do
      guest_vote
      assert_difference('Vote.count' => 0, 'Argu::Redis.keys("temporary*").count' => -1) do
        guest_vote.destroy
      end
      vote = create_vote(user)
      assert_difference('Vote.count' => -1, 'Argu::Redis.keys("temporary*").count' => 0) do
        vote.destroy
      end
      unconfirmed_vote = create_vote(unconfirmed)
      assert_difference('Vote.count' => -1, 'Argu::Redis.keys("temporary*").count' => 0) do
        unconfirmed_vote.destroy
      end
    end

    test 'destroy parent' do
      guest_vote
      assert_difference('Motion.count' => -1, 'Vote.count' => 0, 'Argu::Redis.keys("temporary*").count' => -1) do
        guest_vote.parent.parent.destroy
      end
    end

    test 'persist' do
      redis_resource =
        RedisResource::Resource
          .find("temporary.guest_user.#{guest_user.id}.#{guest_vote.root_id}.vote.#{guest_vote.parent.id}")
      assert_difference('Vote.count' => 1, 'Argu::Redis.keys("temporary*").count' => -1) do
        redis_resource.persist(user)
      end
    end

    test 'persist when already present in postgres' do
      vote
      redis_resource =
        RedisResource::Resource
          .find("temporary.guest_user.#{guest_user.id}.#{guest_vote.root_id}.vote.#{guest_vote.parent.id}")
      assert_difference('Vote.count' => 0, 'Argu::Redis.keys("temporary*").count' => -1) do
        redis_resource.persist(user)
      end
    end

    private

    def create_vote(user, attrs = {})
      Vote.create(
        {
          creator: user.profile,
          publisher: user,
          for: :pro,
          parent: motion.default_vote_event,
          root_id: motion.root_id
        }.merge(attrs)
      )
    end
  end
end
