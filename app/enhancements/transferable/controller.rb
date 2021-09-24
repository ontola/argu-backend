# frozen_string_literal: true

module Transferable
  module Controller
    extend ActiveSupport::Concern

    included do
      has_resource_action(
        :transfer,
        form: TransferForm,
        http_method: :put,
        image: 'fa-exchange',
        policy: :transfer?
      )
    end

    def transfer_execute
      current_resource.transfer!(permit_params.require(:transfer_to))
    end

    def transfer_success
      respond_with_updated_resource(transfer_success_options)
    end

    def transfer_success_message; end

    def transfer_success_options
      update_success_options.merge(meta: update_meta)
    end
  end
end
