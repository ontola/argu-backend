module Publishable


end

require 'publishable/publishers'
require 'publishable/wrappers'

ActiveSupport.on_load(:active_record) do
  extend Publishable::Schemeable
end
