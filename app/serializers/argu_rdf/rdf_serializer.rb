# frozen_string_literal: true

module ArguRDF
  module RDFSerializer
    def _type
      object.type.is_a?(Array) ? object.type.first.to_s : object.type.to_s
    end

    def attributes(requested_attrs = nil, reload = false)
      @attributes = nil if reload
      return @attributes if @attributes.present?

      base_attrs = self.class._attributes_data.each_with_object({}) do |(key, attr), hash|
        next if attr.excluded?(self)
        # next unless requested_attrs&.include?(key)
        hash[key] = attr.value(self)
      end

      attrs = object.to_hash
      # attrs['@context'] = (base_attrs['@context'] || ld_context).merge(attrs['@context'])
      attrs['@context'] = ld_context

      @attributes = base_attrs.merge(attrs)
    end
  end
end
