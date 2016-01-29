module ExceptionToTheRule
  TRICKLE_LOGIC = { 'doesnt_trickle' => :==, 'trickles_down' => :<=, 'trickles_up' => :>= }

  def apply_rules(action, level)
    if context.context_model.present?
      rules = filter_trickle(find_rules_for_action(action), level)
    end
    if rules.present?
      rules.map { |r| r.permit ? level : nil }.compact.presence
    else
      level
    end
  end

  def filter_trickle(rules, level)
    rules.find_all { |r| level.send(TRICKLE_LOGIC[r.trickles], self.send(r.role)) } if level
  end

  # Waarschijnlijk een context_type nil toevoegen aan het eerste query gedeelte.
  def find_rules_for_action(action)
    _rules = Rule.arel_table
    rule_query = _rules[:model_type].eq(@record.is_a?(Class) ? @record.to_s : @record.class.to_s)
                   .and(_rules[:model_id].eq(@record.try(:id))
                   .and(_rules[:action].eq(action.to_s))
                   .and(_rules[:context_type].eq(context.context_model.class.to_s))
                   .and(_rules[:context_id].eq(context.context_model.id.to_s))
                 )
    Rule.where(rule_query)
  end

  def max_clearance(*array)
    array.flatten.compact.max.presence
  end

  def rule(*array)
    level = max_clearance(array)
    apply_rules(caller_locations(1,1)[0].label, level)
  end
end
