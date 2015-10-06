class QuoteBanner < Banner
  belongs_to :cited_profile, class_name: 'Profile'

end