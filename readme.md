Argu
=============
[![Build Status](https://semaphoreapp.com/api/v1/projects/40e97aeb-334e-4b28-ac4e-844fa5db7c50/289369/badge.png)](https://semaphoreapp.com/fletcher91/argu--2)

Setting up
--------------
1. Clone the repo `git clone git@bitbucket.org:arguweb/argu.git`
2. Install the gems `bundle install`
3. Set up the db `rake db:setup`
4. Start the server `rails s`
5. Start the background worker: `bundle exec sidekiq`

New Features
------------
When adding a new feature, make use of `if active_for_user?(feature, user)` so we can roll out the feature gradually.

To add the feature for staff members, execute `$rollout.activate_group(:feature, :staff)` for info.

Enviroment variables
----------------------------
Key / Environment variable                                            |  Use
-------------------------------------------------------------------   |  -----------------------------------------------------------------------------------------------------------------------------
`HOSTNAME`                                                            |  The hostname used in url helpers, mailers, session store, etc
`LOG_LEVEL`                                                           |  The log level of rails, duh.

Secrets.yml file
---------------------------
Rails 4 uses secret.yml, [see the docs](http://guides.rubyonrails.org/4_1_release_notes.html#config-secrets-yml),
and [the docs](http://unixhelp.ed.ac.uk/CGI/man-cgi?ls) to symlink a file.

Key / Environment variable                                            |  Use
-------------------------------------------------------------------   |  -----------------------------------------------------------------------------------------------------------------------------
`secret_token`                                                        |  Use `rake secret` to generate
`secret_key_base`                                                     |  Use `rake secret` to generate
`argu_gmail_pass`                                                     |  Used for ActionMailer/Devise
`aws_id`                                                              |  Used to store images
`aws_key`                                                             |  Used to store images
`mailgun_api_token`                                                   |  Used for sending notification email
`mailgun_sender`                                                      |  Used for sending notification email


***
Legal:

Copyright 2015 Thom van Kalkeren & Joep Meindertsma - All rights reserved

info@argu.co