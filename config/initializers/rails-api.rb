# Lets use the JSON api adapter so we generate http://jsonapi.org/ conforming JSON
ActiveModel::Serializer.config.adapter = :json_api
