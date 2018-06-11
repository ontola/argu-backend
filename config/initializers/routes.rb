# frozen_string_literal: true

module ActionDispatch
  module Journey
    class Routes
      def simulator
        @simulator ||= begin
          gtg = GTG::Builder.new(ast).transition_table if ast.present?
          GTG::Simulator.new(gtg)
        end
      end
    end
  end
end
