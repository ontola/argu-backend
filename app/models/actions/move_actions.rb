# frozen_string_literal: true

module Actions
  class MoveActions < Base
    private

    def association_class
      Move
    end

    def create_description
      I18n.t('actions.default.move.description')
    end

    def create_on_collection?
      false
    end

    def create_policy
      :create?
    end

    def new_label
      I18n.t('actions.default.move.label')
    end
  end
end
