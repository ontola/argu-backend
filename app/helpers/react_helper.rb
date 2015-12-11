module ReactHelper

  def add_to_state(key, value)
    if initial_js_state[key].is_a?(Hash)
      initial_js_state[key].merge(value)
    else
      initial_js_state[key] = value
    end
  end

  def localized_react_component(opts)
    {
        locales: [I18n.locale],
        messages: {
            pro: t('votes.type.pro'),
            neutral: t('votes.type.neutral'),
            con: t('votes.type.con'),
            errors: {
                general: t('errors.general'),
                status: {
                    :'404' => t('status.404'),
                    :'401' => t('status.401'),
                    :'429' => t('status.429'),
                    :'500' => t('status.500')
                }
            }
        }
    }.merge! opts
  end

  def merge_state(hash)
    @initial_js_state = initial_js_state.merge(hash)
  end

  def override_state(key, value)
    initial_js_state[key] = value
  end

  private

  def initial_js_state
    @initial_js_state ||= HashWithIndifferentAccess.new
  end
end
