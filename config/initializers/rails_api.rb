# frozen_string_literal: true

require 'argu/linked_json_api_adapter'
# Lets use the JSON api adapter so we generate http://jsonapi.org/ conforming JSON
ActiveModelSerializers::Adapter.register(:linked_json_api_adapter, Argu::LinkedJsonApiAdapter)
ActiveModel::Serializer.config.adapter = :linked_json_api_adapter
