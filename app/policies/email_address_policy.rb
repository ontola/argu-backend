# frozen_string_literal: true

class EmailAddressPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  def permitted_attribute_names
    attrs = super
    attrs.append(:email) if new_record?
    attrs.append(:primary) if make_primary?
    attrs
  end

  def create?
    show?
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
