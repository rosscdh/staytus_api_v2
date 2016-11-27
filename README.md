V2 REST API for Staytus
-----------------------

Restful api for the fabulous: https://github.com/adamcooke/staytus


But why?
========

1. Staytus is not really implemented using good REST standards (i.e. using POST for GET events)
2. requires multiple queries for issue_updates to get the base issue details
3. I wanted to build something using grape


Install
=======

1. place in rails /lib/staytus_api_v2
2. add Mount to routes.rb
3. Profit


**routes.rb**

```
  #
  # v2 api
  #
  mount StaytusApiV2::API => '/'
```