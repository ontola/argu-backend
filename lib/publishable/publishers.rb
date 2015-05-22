module Publishable

  module Publishers
    class Publisher

    end

    Dir[File.join(File.dirname(__FILE__), "/publishers/*.rb")].each { |f| require f }
  end
end
