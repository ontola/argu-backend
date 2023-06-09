# frozen_string_literal: true

module Menus
  class List < LinkedRails::Menus::List
    class << self
      def custom_menu(params, user_context)
        menu_list = menu_list_from_params(params, user_context)
        menu_tag = params[:id]&.to_sym
        resource = menu_list.send(:resource)

        return unless resource.is_a?(Edge)

        LinkedRails.menus_item_class.new(
          menus: menu_list.custom_menu_items(menu_tag, resource),
          parent: menu_list,
          resource: resource,
          tag: menu_tag
        )
      end

      def requested_single_resource(params, user_context)
        super || custom_menu(params, user_context)
      end
    end
  end
end
