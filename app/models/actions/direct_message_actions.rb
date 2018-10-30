# frozen_string_literal: true

module Actions
  class DirectMessageActions < Base
    private

    def create_description
      I18n.t('actions.direct_messages.create.description', creator: resource.resource.publisher.display_name)
    end

    def create_on_collection?
      false
    end

    def create_policy
      :create?
    end

    def new_label
      I18n.t('actions.direct_messages.create.label')
    end
  end
end
