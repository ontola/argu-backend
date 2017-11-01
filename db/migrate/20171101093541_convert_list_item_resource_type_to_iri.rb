class ConvertListItemResourceTypeToIRI < ActiveRecord::Migration[5.1]
  PREFIX_INDEX = 0
  TERM_INDEX = 1

  def change
    ListItem.find_in_batches do |list_items|
      list_items.each do |list_item|
        resource_type = list_item.resource_type.split(':')
        full_type =
          case resource_type[PREFIX_INDEX]
          when 'argu'
            RDF::ARGU[resource_type[TERM_INDEX]]
          when 'schema'
            RDF::SCHEMA[resource_type[TERM_INDEX]]
          else
            raise Error.new('prefix not known')
          end
        list_item.update(resource_type: full_type)
      end
    end
  end
end
