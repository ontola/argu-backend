# frozen_string_literal: true
module Decisionable
  extend ActiveSupport::Concern

  included do
    has_many :decisions,
             -> { order(step: :asc) },
             through: :edge
    has_one :last_decision,
            -> { published.order(step: :desc) },
            through: :edge,
            source: :decisions,
            class_name: 'Decision'

    # @return [Boolean] Whether this Decision is assigned to the `to_user` or one of its groups
    def assigned_to_user?(to_user)
      to_user.present? &&
        (to_user == assigned_user || (to_user.profile.groups.include?(assigned_group) && assigned_user.nil?))
    end

    def assigned_user
      last_decision.present? ? last_decision.forwarded_user : forum.default_decision_user
    end

    def assigned_group
      last_decision.present? ? last_decision.forwarded_group : forum.default_decision_group
    end

    def state
      last_or_new_decision.forwarded? ? 'pending' : last_or_new_decision.state
    end

    def last_or_new_decision
      @last_or_new_decision ||= last_decision || new_decision
    end

    def new_decision(state = :pending)
      Edge.new(owner: Decision.new(forum: forum, state: state), parent: edge).owner
    end
  end
end
