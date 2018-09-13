# frozen_string_literal: true

module ActiveRecordWith
  def build_arel(arel)
    result = super
    result.with(with_clause) if with_clause
    result
  end

  def with(arel)
    spawn.with!(arel)
  end

  def with!(arel)
    self.with_clause ||= []
    self.with_clause << arel
    self
  end

  def with_clause
    get_value(:with_clause)
  end

  def with_clause=(value)
    set_value(:with_clause, value)
  end
end

ActiveRecord::Relation.send(:prepend, ActiveRecordWith)
