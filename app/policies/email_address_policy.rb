# frozen_string_literal: true

class EmailAddressPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  permit_attributes %i[email], new_record: true
  permit_attributes %i[primary], has_values: {primary: false}

  def create?
    show? || record.user.nil?
  end

  def show?
    record.user == user || service?
  end

  def update?
    show?
  end

  def confirm?
    !record.confirmed?
  end

  def destroy?
    !record.primary?
  end

  def make_primary?
    !record.primary? && (record.confirmed? || !record.user.confirmed?)
  end
end
