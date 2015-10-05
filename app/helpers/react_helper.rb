module ReactHelper
  def localized_react_component(opts)
    {
        locales: [I18n.locale],
        messages: {
            pro: t('votes.type.pro'),
            neutral: t('votes.type.neutral'),
            con: t('votes.type.con')
        }
    }.merge! opts
  end
end
