# frozen_string_literal: true

module Decisionable
  extend ActiveSupport::Concern

  included do
    has_many_through_edge :decisions
    has_one_through_edge :last_decision
    has_one_through_edge :last_published_decision
    with_collection :decisions, pagination: true

    # @return [Boolean] Whether this Decision is assigned to the `to_user` or one of its groups
    def assigned_to_user?(to_user)
      to_user.present? &&
        (to_user == assigned_user || (to_user.profile.groups.include?(assigned_group) && assigned_user.nil?))
    end

    def assigned_user
      if last_published_decision.present?
        last_published_decision.forwarded_user
      else
        parent_model(:forum).default_decision_user
      end
    end

    def assigned_group
      if last_published_decision.present?
        last_published_decision.forwarded_group
      else
        parent_model(:forum).default_decision_group
      end
    end

    def state
      last_or_new_decision.forwarded? ? 'pending' : last_or_new_decision.state
    end

    def last_or_new_decision(drafts = false)
      @last_or_new_decision ||= {}
      @last_or_new_decision[drafts] ||= (drafts ? last_decision : last_published_decision) || new_decision
    end

    def new_decision(state = :pending)
      Edge.new(owner: Decision.new(state: state), parent: edge).owner
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :decisions, predicate: NS::ARGU[:decisions]
    end
  end
end
