## mock-endpoints
This is made to satisfy the requirements for a service that implements the creation of mock endpoints.

Bundled Requirements:
- sinatra
- mysql2
- json
- test/unit
- rack/test

  Implementation:
  - In one terminal window, launch the server file endpoints.rb
  - Send data to the localhost endpoint. An example using curl is:
     curl -v http://127.0.0.1:4567/endpoints/9 -X PATCH -d '{"data": {"type": "endpoints", "attributes": { "verb": "GET", "path": "production/29/jc", "response": {"code": 200, "headers": {}, "body": { "message": "I am trying to update this" } } } } }'
  - To run the test, simply open another window and execute the test_endpoints file.
