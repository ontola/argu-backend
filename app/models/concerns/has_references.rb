module HasReferences
  extend ActiveSupport::Concern

  included do
  end


  #TODO escape content=(text)
  def supped_content
    refs = 0
    content.gsub(/(\[[\w\\\/\:\?\(\)\&\%\_\=\.\+\-\,\#]*\])(\([\w\s!@#\$%^&*,.<>?|\(\)\\\/]*\))/) {|url,text| '<a class="reference-inline" href="%s#ref%d">%d</a>' % [Rails.application.routes.url_helpers.argument_path(self), refs += 1, refs] }
  end

  def references
    refs = 0
    content.scan(/\[([\w\\\/\:\?\(\)\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s!@#\$%^&*,.<>?\(\)|\\\/]*)\)/).each { |r| r << 'ref' + (refs += 1).to_s }
  end

  module ClassMethods
  end
end
