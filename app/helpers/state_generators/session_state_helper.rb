module StateGenerators
  module SessionStateHelper
    def session_state
      @profile = current_profile
      JSON.parse(render(partial: 'users/current_actor', formats: 'json'))['current_actor']
    end
  end
end
