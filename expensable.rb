# Start here. Happy coding!
require "terminal-table"
require "httparty"
require 'json'
require_relative "methods"
require_relative 'sessions'
require_relative 'expenses'

class Expensable

  attr_accessor :expenses, :income, :user, :categories
  include Methods
  def start
    # Ya tengo mi start ahora debo hacer el loop del login 
    action = ""
    until action == "exit"
      begin
        puts welcome
        puts print_menu(:menu_login)
        action = get_inputs(print_menu(:menu_login))
        case action
        when "login"
          login
        when "create_user"
          create_user
        when "exit"
          puts bye
        end
      
      rescue HTTParty::ResponseError => e
        parsed_error = JSON.parse(e.message, symbolize_names: true)
      puts parsed_error[:errors]
      end
    end
  end

  def login
    login_data = login_form
    @user = Sessions.login(login_data)
    puts "Welcome back #{user[:first_name]}"
    expenses_page
  end

  def create_user
    data = login_form_new_user
    @user = Sessions.signup(data)
    puts "Welcome to Expensable #{user[:first_name]}"
    expenses_page
  end

  def expenses_page 
    @categories = Expenses.index(user[:token])

    @expenses = categories.select do |item|
      item[:transaction_type] == "expense"
    end

    @income = categories.select do |item|
      item[:transaction_type] == "income"
    end

    puts notes_table(expenses, "Expenses") # PODEMOS IMPRIMIR EXPENSES O INCOME POR EL PARAMETRO
    puts print_menu(:menu_categories)

  end

  def notes_table(table_data, title)
    table = Terminal::Table.new
    table.title = "#{title}\nDecember 2021"
    table.headings = ['ID', 'Category', 'Total']
    table.rows = table_data.map do |category|
      suma = 0
      category[:transactions].each { |item| suma += item[:amount]}
      [category[:id], category[:name], suma]
    end
    table
  end
end





app = Expensable.new
app.start