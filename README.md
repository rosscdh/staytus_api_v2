V2 REST API for Staytus
=======================

Restful api for the fabulous: https://github.com/adamcooke/staytus

Important
---------

In Staytus there is a bit of confusion around the fields `state` and `status`.
The difference is not clear to the api consumer. And in order to make the distinction a little clearer the following action has been made.

`state` becomes `current_action` 

Which can have one of the following values: ['investigating', 'identified', 'monitoring', 'resolved']

Now its much clearer (for me anyway) which field represents which business object.


But why?
--------

1. Staytus is not really implemented using good REST standards (i.e. It uses for whatever reason POST for events that should be GET and makes assumptions about naming conventions and using /create instead of POST on base objects)
2. requires multiple queries for issue_updates to get the base issue details
3. id or identifier? make a choice and stick with it
4. UUID or short UUID? make a choice and stick with it
5. I wanted to build something using grape


Install
-------

1. place in rails /lib/staytus_api_v2
2. add Mount to routes.rb
3. `gem uninstall moonroap` (beacuse its a namespace hog and wont give up the ghost with "api/v*")
3. Profit, from restful (GET,POST,PATCH,DELETE) routes at /api/v2/issues, /api/v2/issues/:uuid/updates, /api/v2/issues/:uuid/updates/:update_identifier


**routes.rb**

```
  #
  # v2 api
  #
  mount StaytusApiV2::API => '/'
```


Examples
--------

Use https://httpie.org because who uses curl anymore


```
#--------------------------------------------------------------------------------
# Oh no! a new Event has happened, quickly lets tell the world
#--------------------------------------------------------------------------------

# Show me issues
http GET http://localhost:5000/api/v2/issues

# Create a new issue
http POST http://localhost:5000/api/v2/issues title='A title' text='text goes here' status='operational' current_action='investigating'

# Show me the issue again please
http GET http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f

# Nah, i didnt like that text, update the issue
http PATCH http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f title='My new title' text='Some new text' status='operational'

# Nah, Delete this dumb issue
http DELETE http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f

# --------------------------------------------------------------------------------
# Event Update
# Ah great, we are working our way through the issue resolution chain of events
# ['investigating', 'identified', 'monitoring', 'resolved']
# --------------------------------------------------------------------------------

# Get the issues updates
http GET http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates

#
# Create a new update
# you would normally use this event the most, as it keeps adding new sub-issues and keeps the history of the event
# work through the response action chain like so: ['investigating', 'identified', 'monitoring', 'resolved']
#
http POST http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates text='some awesome news here' status='operational' current_action='investigating'

#
# Update an existing update
# You could if you wanted update an existing sub-issue
#
http PATCH http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates/ab2a4e2c3cb8 text='Argh' status='degraded-performance' current_action='investigating'

# Delete an update
http DELETE http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates/ab2a4e2c3cb8
```