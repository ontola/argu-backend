module ReactHelper
  include ForumsHelper, ::StateGenerators::NavbarAppHelper, ::StateGenerators::SessionStateHelper,
          ReactOnRailsHelper

  def react_component_store(name, **opts)
    initialize_shared_store
    react_component(name, **opts)
  end

  def add_to_state(key, value)
    if initial_js_state[key].is_a?(Hash)
      initial_js_state[key].merge!(value)
    else
      initial_js_state[key] = value
    end
  end

  def localized_react_component(opts)
    {
        locales: [I18n.locale],
        messages: {
            pro: t('motions.votes.pro'),
            neutral: t('motions.votes.neutral'),
            con: t('motions.votes.con'),
            errors: {
                general: t('errors.general'),
                status: {
                    '404': t('status.404'),
                    '401': t('status.401'),
                    '429': t('status.429'),
                    '500': t('status.500')
                }
            }
        }
    }.merge! opts
  end

  def merge_state(hash)
    @initial_js_state = initial_js_state.merge(hash)
  end

  def merge_state_for_props(state, props)
    {
      initial_js_state: merge_state(state)
    }.merge(props)
  end

  def override_state(key, value)
    initial_js_state[key] = value
  end

  private

  def initialize_shared_store
    return if @_argu_store_initialized == self
    @_argu_store_initialized = self
    add_to_state 'session', session_state
    add_to_state 'navbarApp', navbar_state
    add_to_state 'notifications', notifications_state
    hydrate_store
  end

  def initial_js_state
    @initial_js_state ||= HashWithIndifferentAccess.new
  end

  def hydrate_store
    redux_store('arguStore', props: initial_js_state, defer: true)
  end
end
