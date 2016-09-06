module ReactHelper
  include ForumsHelper, ::StateGenerators::NavbarAppHelper, ::StateGenerators::SessionStateHelper,
          ReactOnRailsHelper
  
  def add_to_state(model)
    if model.is_a?(Array)
      initial_js_state.concat(model)
    elsif model.is_a?(Enumerable)
      initial_js_state.concat(model.to_a)
    else
      initial_js_state << model
    end
  end

  def react_component_store(name, **opts)
    initialize_shared_store
    react_component(name, **opts)
  end
  
  def state_as_jsonapi
    serializer = ActiveModel::Serializer::CollectionSerializer.new(initial_js_state)
    adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)
    adapter.as_json
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

  def override_state(key, value)
    initial_js_state[key] = value
  end

  private

  def initialize_shared_store
    return if @_argu_store_initialized == self
    @_argu_store_initialized = self
    # add_to_state 'session', session_state
    # add_to_state 'navbarApp', navbar_state
    # add_to_state 'notifications', notifications_state
    hydrate_store
  end
  
  def discover(limit = 5)
    return @ds if defined?(@ds)
    
    discover = Forum
      .public_forums
      .includes(:default_profile_photo, :shortname)
      .where(shortnames: {shortname: %w(nederland utrecht houten hollandskroon feedback)})
      .limit(limit)
    add_to_state(discover)
    @ds = discover.ids
  end
  
  def memberships
    return @ms if defined?(@ms)
    if current_profile && current_profile.forum_ids
      memberships =
        Forum
          .includes(:default_profile_photo, :shortname)
          .where(id: current_profile.present? ? current_profile.forum_ids : [])
          .limit(100)
      add_to_state(memberships)
      @ms = memberships.ids
    end
  end

  def initial_js_state
    unless defined?(@initial_js_state)
      @initial_js_state = []
      @initial_js_state << CurrentActor.new(
        actor: current_profile.profileable,
        user_state: user_state,
        discover: discover - (memberships || []),
        memberships: memberships || []
      )
    end
    @initial_js_state
  end

  def hydrate_store
    redux_store(
      'arguStore',
      props: state_as_jsonapi,
      defer: true)
  end
end
