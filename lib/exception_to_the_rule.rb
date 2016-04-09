
# Mixin giving policies the ability to be altered via {Rule} records
# @see {Argu::RuledIt}
# @author Fletcher91 <thom@argu.co>
module ExceptionToTheRule
  TRICKLE_LOGIC = {'doesnt_trickle' => :==, 'trickles_down' => :<=, 'trickles_up' => :>=}
  ROLE_NAMES = %w(open access_token member manager creator moderator owner staff).freeze

  attr_reader :last_enacted, :last_verdict

  # Throw in the level (or levels) of the user and it'll tell you whether the clearance made it.
  # Whenever someone got permission from a group grant, they will be upped to group_grant clearance.
  # @note The permission is determined by the caller's name
  # @author Fletcher91 <thom@argu.co>
  # @param [Array] array An array of clearance levels for the {Context#user}
  # @return [Integer, [nil, String]] The user's clearance level or nil if it was denied with an additional message as a second return value.
  def rule(*array)
    level = max_clearance(array)
    apply_rules(caller_locations(1,1)[0].label, level)
  end

  private

  def apply_rules(action, level)
    if context.context_model.present? && (rules = find_rules_for_action(action)).present?
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
        .concat(filter_groups(group_rules, context))
        .compact
        .first
    @last_enacted
  end

  # @return [Array] Array of the relevant rules
  def filter_trickle(rules, level)
    if level
      trickled_rules = rules.find_all { |r| level.send(TRICKLE_LOGIC[r.trickles], send(r.role)) }
      trickled_rules.present? ?
        trickled_rules.map { |r| r.permit ? level : [nil, r.message] } :
        [level]
    else
      []
    end
  end

  # @return [Array] Array of the relevant rules
  def filter_groups(rules, context)
    if rules && user && (mem_groups = user.profile.groups.where(forum: context.context_model))
      group_ids = rules
                    .map { |r| r.role.split('_') }
                    .select { |arr| arr[0].eql?('groups') }
                    .map(&:last)
      group_identifiers = mem_groups
                            .where(id: group_ids)
                            .map(&:identifier)
      if group_identifiers.present?
        trickled_rules = rules.find_all { |r| group_identifiers.include?(r.role) }
        trickled_rules.present? ?
          trickled_rules.map { |r| r.permit ? group_grant : [nil, r.message] } :
          [level]
      else
        []
      end
    else
      []
    end
  end

  # Waarschijnlijk een context_type nil toevoegen aan het eerste query gedeelte.
  # @return [ActiveRecord::CollectionProxy] All {Rule}s that match the current action for the
  #   current {Context#model} and {RestrictivePolicy#record}
  def find_rules_for_action(action)
    _rules = Rule.arel_table
    rule_query = _rules[:model_type].eq(@record.is_a?(Class) ? @record.to_s : @record.class.to_s)
                   .and(_rules[:model_id].eq(@record.try(:id))
                          .or(_rules[:model_id].eq(nil))
                   .and(_rules[:action].eq(action.to_s))
                   .and(_rules[:context_type].eq(context.context_model.class.to_s))
                   .and(_rules[:context_id].eq(context.context_model.id.to_s))
                 )
    Rule.where(rule_query)
  end

  def max_clearance(*array)
    array.flatten.compact.max.presence
  end
end
