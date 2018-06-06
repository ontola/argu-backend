# frozen_string_literal: true

class Follow < ApplicationRecord
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes
  enhance Destroyable

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, class_name: 'Edge', primary_key: :uuid
  belongs_to :follower, class_name: 'User'

  enum follow_type: {never: 0, decisions: 10, news: 20, reactions: 30}
  counter_culture :followable,
                  column_name: proc { |model|
                    !model.never? ? 'follows_count' : nil
                  },
                  column_names: {['follows.follow_type != ?', Follow.follow_types[:never]] => 'follows_count'}
  validates :follow_type, presence: true
  validate :terms_accepted

  def block!
    update_attribute(:blocked, true)
  end

  def unsubscribe_iri
    RDF::URI(expand_uri_template('follows_unsubscribe_iri', id: id))
  end

  private

  def terms_accepted
    errors.add(:follower, 'Terms not accepted') if follower.last_accepted.nil?
  end
end
