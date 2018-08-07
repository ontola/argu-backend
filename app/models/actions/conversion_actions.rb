# frozen_string_literal: true

module Actions
  class ConversionActions < Base
    private

    def association_class
      Conversion
    end

    def create_on_collection?
      false
    end

    def create_policy
      :create?
    end

    def new_label
      I18n.t('actions.conversions.create.label')
    end
  end
end
