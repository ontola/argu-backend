module ReactHelper
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
end
