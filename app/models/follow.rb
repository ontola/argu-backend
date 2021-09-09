# frozen_string_literal: true

class Follow < ApplicationRecord
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable

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
    update_attribute(:blocked, true) # rubocop:disable Rails/SkipsModelValidations
  end

  def iri(opts = {})
    return @iri if @iri && opts.empty?

    iri ||= ActsAsTenant.with_tenant(followable&.root || ActsAsTenant.current_tenant) { super }
    @iri = iri if opts.empty?
    iri
  end

  def created_at; end

  def display_name; end

  def published_at; end

  private

  def terms_accepted
    errors.add(:follower, 'Terms not accepted') if follower.last_accepted.nil?
  end

  class << self
    def build_new(parent: nil, user_context: nil)
      user = user_context&.user
      user.follows.find_or_initialize_by(followable: parent)
    end

    private

    def permitted_classes
      @permitted_classes ||= Edge.descendants.select { |klass| klass.enhanced_with?(Followable) }.freeze
    end
  end
end
