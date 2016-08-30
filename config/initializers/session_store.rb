# Be sure to restart your server when you modify this file.

domain = Rails.env.test? ? :all : (ENV['HOSTNAME'] == 'all' && :all || ENV['HOSTNAME'] || 'argu.co')

Rails.application.config.session_store(
  :cookie_store,
  key: '_Argu_session',
  domain: domain,
  tld_length: 2)
