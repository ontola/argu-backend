# frozen_string_literal: true

module Argu
  module TestHelpers
    class PolicyTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
      include DefaultPolicyResults

      define_automated_tests_objects
      define_freetown(
        :expired_freetown,
        attributes: {
          url: FactoryBot.attributes_for(:shortname)[:shortname],
          expires_at: 1.minute.ago
        }
      )
      define_freetown(
        :trashed_freetown,
        attributes: {
          url: FactoryBot.attributes_for(:shortname)[:shortname],
          trashed_at: 1.minute.ago
        }
      )
      define_freetown(
        :unpublished_freetown,
        attributes: {
          url: FactoryBot.attributes_for(:shortname)[:shortname],
          is_published: false
        }
      )
      let(:moderator) { create_moderator(page, create(:user)) }
      let(:initiator) { create_initiator(page, create(:user)) }
      let(:participator) { create_participator(page, create(:user)) }
      let(:guest) { GuestUser.new(id: 'my_id') }
      let(:direct_child) { nil }

      let(:linked_record) { LinkedRecord.create_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
      let(:linked_record_argument) { create(:argument, parent: linked_record, publisher: creator) }

      before do
        ActsAsTenant.current_tenant = argu
      end

      ['', 'expired_', 'trashed_', 'unpublished_'].each do |prefix| # rubocop:disable Metrics/BlockLength
        let("#{prefix}question") { create(:question, parent: send("#{prefix}freetown"), publisher: creator) }
        let("#{prefix}forum_motion") { create(:motion, parent: send("#{prefix}freetown"), publisher: creator) }
        let("#{prefix}motion") { create(:motion, parent: send("#{prefix}question"), publisher: creator) }
        let("#{prefix}decision") do
          create(:decision,
                 parent: send("#{prefix}motion"),
                 publisher: creator,
                 state: 'approved')
        end
        let("#{prefix}vote_event") { send("#{prefix}motion").default_vote_event }
        let("#{prefix}vote") { create(:vote, parent: send("#{prefix}vote_event"), publisher: creator) }
        let("#{prefix}pro_argument") { create(:pro_argument, parent: send("#{prefix}motion"), publisher: creator) }
        let("#{prefix}con_argument") { create(:con_argument, parent: send("#{prefix}motion"), publisher: creator) }
        let("#{prefix}comment") { create(:comment, parent: send("#{prefix}pro_argument"), publisher: creator) }
        let("#{prefix}con_argument_comment") do
          create(:comment, parent: send("#{prefix}con_argument"), publisher: creator)
        end
        let("#{prefix}nested_comment") do
          parent = send("#{prefix}pro_argument")
          create(:comment, parent: parent, in_reply_to_id: send("#{prefix}comment").uuid, publisher: creator)
        end
        let("#{prefix}blog_post") do
          parent = send("#{prefix}question")
          create(:blog_post, parent: parent, publisher: creator)
        end
        let("#{prefix}blog_post_comment") { create(:comment, parent: send("#{prefix}blog_post"), publisher: creator) }
      end

      private

      def policy(subject, user)
        self
          .class
          .name
          .gsub('Test', '')
          .constantize
          .new(UserContext.new(doorkeeper_scopes: {},
                               profile: user.profile,
                               user: user), subject)
      end

      def reset_grants(user_type)
        case user_type
        when :spectator
          [freetown, expired_freetown].each do |record|
            record.public_grant = 'spectator'
          end
        when :participator
          [freetown, expired_freetown].each do |record|
            record.public_grant = 'participator'
          end
        when :non_member, :member
          [freetown, expired_freetown].each do |record|
            record.public_grant = 'none'
          end
        end
        [freetown, expired_freetown].each do |record|
          record.send(:reset_public_grant)
        end
      end

      def test_policy(subject, action, test_cases) # rubocop:disable Metrics/AbcSize
        failures = []
        class_name = self.class.name.gsub('PolicyTest', '')
        test_cases.each do |user, expected|
          reset_grants(user)
          subject.try(:reload) unless subject.try(:new_record?)
          result =
            begin
              policy(subject, send(user)).send("#{action}?")
            rescue Argu::Errors::Forbidden
              false
            end
          if expected
            failures << "#{user} should #{action} #{class_name}" unless result
          elsif result
            failures << "#{user} should not #{action} #{class_name}"
          end
        end
        assert failures.empty?, failures.join(', ')
      end
    end
  end
end
