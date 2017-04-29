# frozen_string_literal: true
module Common
  # Prepares the controllers to setup their actions briefly.
  #
  # @see Service::Setup Services have an adjusted implementation
  # @see Common::Create
  # @see Common::Destroy
  # @see Common::Edit
  # @see Common::Index
  # @see Common::New
  # @see Common::Update
  #
  # Basic methods for an action are defined as follows:
  # @example Successful motion#create methods
  #   # The action calls the action method and calls the success or failure handler.
  #   def create
  #     if execute_create
  #       action_handler_successful(authenticated_resource)
  #     else
  #       action_handler_failure(authenticated_resource)
  #     end
  #     action_service.commit
  #   end
  #
  #  # Every action defines its persistence logic in `execute_<action>`.
  #  def execute_create
  #    authenticated_resource.save
  #  end
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
  #     format.json { render status: :created, json: format }
  #     format.json_api { render status: :created, json: format }
  #   end
  #
  # So multiple methods are created for each combination of actions and states.
  # This provides the ability to redefine behaviour at the most appropriate
  # level, without having to redeclare that which isn't changed.
  #
  # @note This module has to be loaded with a separate include statement for
  #   Ruby to let the alias statement detect the `exec_action` method correctly.
  module Setup
    extend ActiveSupport::Concern

    included do
      # Sets up the action and handler methods.
      def self.define_action_methods(action)
        define_action(action)
        define_handlers(action)
      end

      private

      def self.define_action(action)
        define_method(action, instance_method(:exec_action))
      end

      def self.define_handlers(action)
        define_method(
          "#{action}_handler_failure",
          proc do |resource|
            respond_to do |format|
              send("#{action_name}_respond_blocks_failure", resource, format)
            end
          end
        )
        define_method(
          "#{action}_handler_success",
          proc do |resource|
            respond_to do |format|
              send("#{action_name}_respond_blocks_success", resource, format)
            end
          end
        )
      end

      def exec_action
        if send("execute_#{action_name}")
          send("#{action_name}_handler_success", authenticated_resource)
        else
          send("#{action_name}_handler_failure", authenticated_resource)
        end
      end
    end
  end
end
