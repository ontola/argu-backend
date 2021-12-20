# frozen_string_literal: true

class VocabularyPolicy < EdgePolicy
  permit_attributes %i[display_name description tagged_label term_type default_term_display]

  def update?
    return forbid_with_message(I18n.t('vocabularies.errors.system')) if record.system?

    super
  end

  def trash?
    return forbid_with_message(I18n.t('vocabularies.errors.system')) if record.system?

    super
  end

  def destroy?
    return forbid_with_message(I18n.t('vocabularies.errors.system')) if record.system?

    super
  end
end
