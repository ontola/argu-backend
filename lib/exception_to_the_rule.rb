module ExceptionToTheRule

  def find_rules_for_level(action, level)
    rules = Rule.where(model_type: @record.is_a?(Class) ? @record.to_s : @record.class.to_s,
                       model_id: @record.try(:id),
                       action: action.to_s,
                       context: context.context_model)
    rules = rules.reject { |r| level != self.send(r.role) } if level
    rules
  end

  def apply_rules(action, level)
    rules = find_rules_for_level(action, level)
    rules.presence ? rules.map { |r| r.permit ? level : nil }.compact.presence : level
  end

  def max_clearance(*array)
    array.flatten.compact.max.presence
  end

  def rule(*array)
    level = max_clearance(array)
    apply_rules(caller_locations(1,1)[0].label, level)
  end
end
