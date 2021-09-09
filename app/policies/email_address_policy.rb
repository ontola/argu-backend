# frozen_string_literal: true

class EmailAddressPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

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
    return forbid_with_status(NS.schema.CompletedActionStatus, forbid_message('confirm.completed')) if record.confirmed?

    true
  end

  def destroy?
    return forbid_with_message(forbid_message('destroy.primary')) if record.primary?

    true
  end

  def make_primary?
    if record.primary?
      return forbid_with_status(NS.schema.CompletedActionStatus, forbid_message('make_primary.completed'))
    end
    if !record.confirmed? && record.user.confirmed?
      return forbid_with_message(forbid_message('make_primary.unconfirmed'))
    end

    true
  end

  def forbid_message(key)
    I18n.t("actions.email_addresses.#{key}")
  end
end
