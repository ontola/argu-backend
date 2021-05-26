# frozen_string_literal: true

module Menus
  class List < LinkedRails::Menus::List
    class << self
      def single_resource_from_params(params, user_context)
        super || custom_menu(params, user_context)
      end

      def custom_menu(params, user_context)
        menu_list = menu_list_from_params(params, user_context)
        menu_tag = params[:id]&.to_sym
        resource = menu_list.send(:resource)

        LinkedRails.menus_item_class.new(
          menus: menu_list.custom_menu_items(menu_tag, resource),
          parent: menu_list,
          resource: resource,
          tag: menu_tag
        )
      end
    end
  end
end
