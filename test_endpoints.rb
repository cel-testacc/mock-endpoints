ENV['APP_ENV'] = 'test'

require_relative 'endpoints'
require 'test/unit'
require 'rack/test'
require 'json'

class TopQuotesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_default_endpoints
    get '/endpoints'
    assert last_response.ok?
    inclusion = {"id":1,"path":"greeting","verb":"GET","code":200,"headers":"","body":{"message":"Hello, world"}}
    assert last_response.body.include?(JSON.generate(inclusion))
  end

  def test_post_endpoint
    inclusion = {"data": {"type": "endpoints", "attributes": { "verb": "GET", "path": "/greeting", "response": {"code": 200, "headers": {}, "body": "\"{ \"message\": \"Hello, world\" }\""} } } }
    post '/endpoints', inclusion.to_json
    assert last_response.body.include?("this path already exists")
  end


  def test_patch_endpoint
    inclusion = {"data": {"type": "endpoints", "attributes": { "verb": "GET", "path": "/greeting", "response": {"code": 200, "headers": {}} } } }
    patch '/endpoints/1', inclusion.to_json 
    assert last_response.body.include?("No response body sent in request")
  end

  def test_delete_endpoint
    delete '/endpoints/99'
    assert last_response.body.include?("Not found")
  end

end