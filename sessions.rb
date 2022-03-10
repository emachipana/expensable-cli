require "httparty"
require 'json'

class Sessions
  include HTTParty

  base_uri('https://expensable-api.herokuapp.com/')

  def self.login(login_data)
    options = {
        headers: { "Content-Type": "application/json" },
        body: login_data.to_json
      }
    response = post('/login',options)
    raise HTTParty::ResponseError.new(response) unless response.success?
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.signup(data)
    options = {
      headers: { "Content-Type": "application/json" },
      body: data.to_json
    }
    response = post('/signup', options)
    raise raise HTTParty::ResponseError.new(response) unless response.success?
    JSON.parse(response.body, symbolize_names: true)
  end
end