module Publishable

  module Schema


    Dir[File.join(File.dirname(__FILE__), "/schema/*.rb")].each { |f| require f }
  end
end
