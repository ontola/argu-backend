# frozen_string_literal: true

require 'argu/test_helpers/default_policy_tests'
require 'argu/test_helpers/default_policy_results'

class PolicyTest < ActiveSupport::TestCase
  include DefaultPolicyResults

  define_automated_tests_objects
  define_public_source
  define_freetown(:expired_freetown, attributes: {edge_attributes: {expires_at: 1.minute.ago}})
  define_freetown(:trashed_freetown, attributes: {edge_attributes: {trashed_at: 1.minute.ago}})
  define_freetown(:unpublished_freetown, attributes: {edge_attributes: {is_published: false}})
  let(:moderator) { create_moderator(page, create(:user)) }
  let(:initiator) { create_initiator(page, create(:user)) }
  let(:participator) { create_participator(page, create(:user)) }
  let(:guest) { GuestUser.new(id: 'my_id') }

  let(:linked_record) { create(:linked_record, source: public_source) }
  let(:linked_record_argument) { create(:argument, parent: linked_record.edge, publisher: creator) }

  ['', 'expired_', 'trashed_', 'unpublished_'].each do |prefix|
    let("#{prefix}project") { create(:project, parent: send("#{prefix}freetown").edge, publisher: creator) }
    let("#{prefix}phase") { create(:phase, parent: send("#{prefix}project").edge, publisher: creator) }
    let("#{prefix}question") { create(:question, parent: send("#{prefix}freetown").edge, publisher: creator) }
    let("#{prefix}forum_motion") { create(:motion, parent: send("#{prefix}freetown").edge, publisher: creator) }
    let("#{prefix}motion") { create(:motion, parent: send("#{prefix}question").edge, publisher: creator) }
    let("#{prefix}decision") do
      create(:decision,
             parent: send("#{prefix}motion").edge,
             publisher: creator,
             state: 'approved',
             happening_attributes: {happened_at: Time.current})
    end
    let("#{prefix}vote_event") { send("#{prefix}motion").default_vote_event }
    let("#{prefix}vote") { create(:vote, parent: send("#{prefix}vote_event").edge, publisher: creator) }
    let("#{prefix}argument") { create(:argument, parent: send("#{prefix}motion").edge, publisher: creator) }
    let("#{prefix}comment") { create(:comment, parent: send("#{prefix}argument").edge, publisher: creator) }
    let("#{prefix}nested_comment") do
      parent = send("#{prefix}argument").edge
      create(:comment, parent: parent, parent_id: send("#{prefix}comment").id, publisher: creator)
    end
    let("#{prefix}blog_post") do
      parent = send("#{prefix}question").edge
      create(:blog_post, parent: parent, publisher: creator, happening_attributes: {happened_at: Time.current})
    end
    let("#{prefix}blog_post_comment") { create(:comment, parent: send("#{prefix}blog_post").edge, publisher: creator) }
  end

  private

  def policy(subject, user)
    self
      .class
      .name
      .gsub('Test', '')
      .constantize
      .new(UserContext.new(user, user.profile, {}, GrantTree::ANY_ROOT), subject)
  end

  def reset_grants(subject, user_type)
    subject.open! if subject.is_a?(Page)
    case user_type
    when :spectator
      [freetown, expired_freetown, public_source].each do |record|
        record.public_grant = 'spectator'
      end
    when :participator
      [freetown, expired_freetown, public_source].each do |record|
        record.public_grant = 'participator'
      end
    when :non_member, :member
      [freetown, expired_freetown, public_source].each do |record|
        record.public_grant = 'none'
      end
      subject.closed! if subject.is_a?(Page)
    end
    [freetown, expired_freetown, public_source].each do |record|
      record.send(:reset_public_grant)
    end
  end

  def test_policy(subject, action, test_cases)
    failures = []
    class_name = self.class.name.gsub('PolicyTest', '')
    test_cases.each do |user, expected|
      reset_grants(subject, user)
      subject.try(:reload) unless subject.try(:new_record?)
      result =
        begin
          policy(subject, send(user)).send("#{action}?")
        rescue Argu::Errors::NotAuthorized
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
