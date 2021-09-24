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
      let(:guest) { User.guest('my_id') }
      let(:direct_child) { nil }

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
          create(:comment, parent: parent, parent_comment_id: send("#{prefix}comment").uuid, publisher: creator)
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
          .new(UserContext.new(profile: user.profile, user: user), subject)
      end

      def reset_grants(user_type)
        case user_type
        when :spectator
          self.public_grants = :spectator
        when :participator
          self.public_grants = :participator
        when :non_member, :member
          self.public_grants = nil
        else
          self.public_grants = :initiator
        end
      end

      def public_grants=(grant_set)
        [freetown, expired_freetown].each do |record|
          record.initial_public_grant = grant_set
          record.send(:create_default_grant)
        end
      end

      def test_crud_policies
        direct_child

        %i[create show update destroy].each do |method|
          test_policy(subject, method, send("#{method}_results"))
        end
      end

      def test_edgeable_policies # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        test_crud_policies

        %i[trash follow log invite move convert feed].each do |method|
          test_policy(subject, method, send("#{method}_results"))
        end

        test_policy(unpublished_subject, :show, show_unpublished_results) if unpublished_subject
        test_policy(expired_subject, :show, show_expired_results) if expired_subject
        test_policy(expired_subject, :show, show_trashed_results) if trashed_subject
        test_policy(expired_subject, :create, create_expired_results) if expired_subject
        test_policy(trashed_subject, :create, create_trashed_results) if trashed_subject
        direct_child&.update(publisher: create(:user))
        test_policy(subject, :destroy, destroy_with_children_results) if direct_child
      end

      def test_policy(subject, action, test_cases) # rubocop:disable Metrics/MethodLength
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
