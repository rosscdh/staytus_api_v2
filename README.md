V2 REST API for Staytus
=======================

Restful api for the fabulous: https://github.com/adamcooke/staytus


But why?
--------

1. Staytus is not really implemented using good REST standards (i.e. using POST for GET events)
2. requires multiple queries for issue_updates to get the base issue details
3. I wanted to build something using grape


Install
-------

1. place in rails /lib/staytus_api_v2
2. add Mount to routes.rb
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
#
# Issues
#

# Show me issues
http GET http://localhost:5000/api/v2/issues

# Create a new issue
http POST http://localhost:5000/api/v2/issues title='A title' text='text goes here' status='operational' state='investigating'

# Show me the issue again please
http GET http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f

# Nah, i didnt like that text, update the issue
http PATCH http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f title='My new title' text='Some new text' status='operational' state='investigating'

# Nah, Delete this dumb issue
http DELETE http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f

#
# Sub issues
#

# Get the issues updates
http GET http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates

# Create a new update
http POST http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates text='some awesome news here' status='operational' state='investigating'

# Create a new update
http PATCH http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates/ab2a4e2c3cb8 text='Argh' status='degraded-performance' state='investigating'

# Delete an update
http DELETE http://localhost:5000/api/v2/issues/fc43ebb4-90be-4164-94a9-ba023944ce4f/updates/ab2a4e2c3cb8
```