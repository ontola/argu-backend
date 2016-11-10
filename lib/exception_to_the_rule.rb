# frozen_string_literal: true

# Mixin giving policies the ability to be altered via {Rule} records
# @see {Argu::RuledIt}
# @author Fletcher91 <thom@argu.co>
module ExceptionToTheRule
  TRICKLE_LOGIC = {'doesnt_trickle' => :==, 'trickles_down' => :<=, 'trickles_up' => :>=}.freeze
  ROLE_NAMES = %w(open member manager creator moderator super_admin staff).freeze

  attr_reader :last_enacted, :last_verdict

  # Throw in the level (or levels) of the user and it'll tell you whether the clearance made it.
  # Whenever someone got permission from a group grant, they will be upped to group_grant clearance.
  # @note The permission is determined by the caller's name
  # @author Fletcher91 <thom@argu.co>
  # @param [Array] array An array of clearance levels for the {Context#user}
  # @return [Integer, [nil, String]] The user's clearance level or nil if it was
  #                                    denied with an additional message as a second return value.
  def rule(*array)
    level = max_clearance(array)
    apply_rules(caller_locations(1, 1)[0].label, level)
  end

  private

  def apply_rules(action, level)
    if persisted_edge.present? && (rules = find_rules_for_action(action)).present?
      filter_rules(rules, level)
    else
      level
    end
  end

  # @return [Array, [nil, message]] Array of the relevant rules or nil if there were none
  def filter_rules(rules, level)
    level_rules, group_rules = rules.partition { |rule| ROLE_NAMES.include?(rule.role) }
    @last_enacted, @last_verdict =
      filter_trickle(level_rules, level)
        .concat(filter_groups(group_rules))
        .select(&:present?)
        .first
    @last_enacted
  end

  # @return [Array] Array of the relevant rules
  def filter_trickle(rules, level)
    if level
      trickled_rules = rules.find_all { |r| level.send(TRICKLE_LOGIC[r.trickles], send(r.role)) }
      if trickled_rules.present?
        trickled_rules.map { |r| r.permit ? level : [nil, r.message] }
      else
        [level]
      end
    else
      []
    end
  end

  # @return [Array] Array of the relevant rules
  def filter_groups(rules)
    if rules && (mem_groups = user.profile.groups.where(page: persisted_edge.root.owner))
      group_ids = rules
                    .map { |r| r.role.split('_') }
                    .select { |arr| arr[0].eql?('groups') }
                    .map(&:last)
      group_identifiers = mem_groups
                            .where(id: group_ids)
                            .map(&:identifier)
      if group_identifiers.present?
        trickled_rules = rules.find_all { |r| group_identifiers.include?(r.role) }
        if trickled_rules.present?
          trickled_rules.map { |r| r.permit ? group_grant : [nil, r.message] }
        else
          [level]
        end
      else
        []
      end
    else
      []
    end
  end

  # @return [ActiveRecord::CollectionProxy] All {Rule}s that match the current action for the
  #   current {RestrictivePolicy#record} anywhere in the current edge tree
  def find_rules_for_action(action)
    t_rules = Rule.arel_table
    rule_query = t_rules[:model_type]
                   .eq(@record.is_a?(Class) ? @record.to_s : @record.class.to_s)
                   .and(t_rules[:model_id].eq(@record.try(:id))
                          .or(t_rules[:model_id].eq(nil))
                          .and(t_rules[:action].eq(action.to_s))
                          .and(t_rules[:branch_id].in(persisted_edge.ancestor_ids)))
    Rule.where(rule_query)
  end

  def max_clearance(*array)
    array.flatten.compact.max.presence
  end
end
