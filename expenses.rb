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

  def self.destroy(token, id) # falta token y ID
    options = {
      headers: { "Authorization": "Token token=#{token}" }
    }
  
    response = delete("/categories/#{id}", options)
    # JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end

  def self.create_expense(token, data)
    options = {
      headers: { 'Content-Type': 'application/json', 
      'Authorization': "Token token=#{token}"},
      body: data.to_json
    }
    response = post('/categories', options)
    JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end
  
  def self.update_category(token, id, data)
    options = {
      headers: {
        'Content-Type': 'application/json',  
        "Authorization": "Token token=#{token}"
      },
      body: data.to_json
    }
    response = patch("/categories/#{id}", options)
    JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end
end
