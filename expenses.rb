require "httparty"
require 'json'


class Expenses
  include HTTParty

  base_uri('https://expensable-api.herokuapp.com')

  def self.index(token)

    options = {
      headers: { "Authorization": "Token token=#{token}" }
      # headers: { "Authorization": "Token token=#{token}" }
    }

    response = get('/categories',options)
    JSON.parse(response.body, symbolize_names: true)
  end
end