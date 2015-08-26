Argu
=============
[![Build Status](https://semaphoreapp.com/api/v1/projects/40e97aeb-334e-4b28-ac4e-844fa5db7c50/289369/badge.png)](https://semaphoreapp.com/fletcher91/argu--2)

Argu is an online discussion platform for substantive debate.

[Visit argu.co](https://argu.co)

Install dependencies
--------------------

Make sure these are installed on your computer:

1. Qt `brew link --force qt5`


Setting up
--------------

Time to set up Argu!

1. Clone the repo `git clone git@bitbucket.org:arguweb/argu.git`
2. Install the gems `bundle install`
3. Set up the db `rake db:setup`. Set it up in all the environments that you will use (development / testing)
4. Start the server `rails s`
5. Run Redis `redis-server`
6. Start the background worker: `bundle exec sidekiq`
7. Go to localhost:3000 or check the run log to see where Argu is running
8. Sign in with `admin@argu.co` & `arguargu`
9. Click 'ADMIN_ACCOUNT' on the bottom right corner of the screen to access the portal
10. Create a page
11. Create a forum with that page
12. Enable the features that require Rollout (see below)

Adding & enabling features using Rollout
------------
When **adding a new feature**, use the `active_for_user` method, so we can roll out the feature gradually or disable it if necessary.

`if active_for_user?(feature, user)`

To **enable a feature** for staff members, execute in the Rails console:

`$rollout.activate_group(:feature, :staff)`

**List of rolloutable features**: (don't forget to add your feature name here)

* argument\_tooltips_list
* argument\_tooltips_content
* notifications
* carousel_buttons
* expires_at
* share_links
* inspectlet
* welcome_video
* groups


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
`devise_secret`                                                       |  Devise secret key base
`argu_gmail_pass`                                                     |  Used for ActionMailer/Devise
`aws_id`                                                              |  Used to store images
`aws_key`                                                             |  Used to store images
`mailgun_api_token`                                                   |  Used for sending notification email
`mailgun_sender`                                                      |  Used for sending notification email


***
Legal:

Copyright 2015 Thom van Kalkeren & Joep Meindertsma - All rights reserved

info@argu.co
