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
    JSON.parse(response.body, symbolize_names: true)
  end
end