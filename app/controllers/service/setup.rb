# frozen_string_literal: true
module Service
  # Implements the {Common::Setup} pattern for controller directed at models
  # implementing the service pattern.
  #
  # @see Common::Setup See the common module for more information
  #
  # Service adjusted example methods are as follows:
  # @example Successful motion#create methods
  #   # A basic action is created which calls to register a success and failure
  #   # handler.
  #   def create
  #     create_register_success
  #     create_register_failure
  #     action_service.commit
  #   end
  #
  #   # The registerer then registers a method to handle the incoming signal.
  #   def create_register_success
  #     action_service.on(
  #       :create_motion_successful,
  #       &:create_handler_successful
  #     )
  #   end
  #
  #   # That handler will receive the acted upon resource as its parameter and
  #   # call the `respond_to` method, passing the resource and `format` hook.
  #   def create_handler_successful(resource)
  #     respond_to do |format|
  #       create_respond_blocks_success(resource, format)
  #     end
  #   end
  #
  #   # Each method and signal then also gets its own block handlers which
  #   # define the behaviour for each content-type.
  #   def create_respond_blocks_success(resource, format)
  #     format.html { create_respond_success_html(resource) }
  #     format.json { render status: :created, json: format }
  #     format.json_api { render status: :created, json: format }
  #   end
  #
  #   # Due to legacy implementations, the html block is separated into a method
  #   # since html behaviour differs greatly between controllers.
  #   def create_respond_success_html()
  #      respond_with_redirect_success(resource, :save)
  #   end
  module Setup
    extend ActiveSupport::Concern

    included do
      private

      def self.define_action_methods(action)
        define_action(action)
        define_handlers(action)
        define_registers(action)
      end

      def self.define_registers(action)
        define_method(
          "#{action}_register_failure",
          proc do
            action_service.on(
              signal_failure,
              &method("#{action}_handler_failure".to_sym)
            )
          end
        )
        define_method(
          "#{action}_register_success",
          proc do
            action_service.on(
              signal_success,
              &method("#{action}_handler_success".to_sym)
            )
          end
        )
      end

      def exec_action
        send("#{action_name}_register_success")
        send("#{action_name}_register_failure")
        action_service.commit
      end
    end
  end
end
