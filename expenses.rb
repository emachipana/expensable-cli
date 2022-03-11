require "httparty"
require "json"

class Expenses
  include HTTParty

  base_uri("https://expensable-api.herokuapp.com")

  def self.index(token)
    options = {
      headers: { Authorization: "Token token=#{token}" }
    }

    response = get("/categories", options)
    JSON.parse(response.body, symbolize_names: true)
  end

  # falta token y ID
  def self.destroy(token, id)
    options = {
      headers: { Authorization: "Token token=#{token}" }
    }

    delete("/categories/#{id}", options)
  end

  def self.create_expense(token, data)
    options = {
      headers: { "Content-Type": "application/json",
                 Authorization: "Token token=#{token}" },
      body: data.to_json
    }
    response = post("/categories", options)
    JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end

  def self.add_transaction(id_tran, token, data)
    options = {
      headers: { "Content-Type": "application/json",
                 Authorization: "Token token=#{token}" },
      body: data.to_json
    }
    response = post("/categories/#{id_tran}/transactions", options)
    JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end

  def self.update_transaction(id_tran, id, token, data)
    options = {
      headers: { "Content-Type": "application/json",
                 Authorization: "Token token=#{token}" },
      body: data.to_json
    }
    response = patch("/categories/#{id_tran}/transactions/#{id}", options)
    JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end

  # falta token y ID
  def self.delete_transaction(id_tran, token, id)
    options = {
      headers: { Authorization: "Token token=#{token}" }
    }

    delete("/categories/#{id_tran}/transactions/#{id}", options)
  end

  def self.update_category(token, id, data)
    options = {
      headers: {
        "Content-Type": "application/json",
        Authorization: "Token token=#{token}"
      },
      body: data.to_json
    }
    response = patch("/categories/#{id}", options)
    JSON.parse(response.body, symbolize_names: true) unless response.body.nil?
  end
end
