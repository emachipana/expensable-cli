# Start here. Happy coding!
require "terminal-table"
require "httparty"
require 'json'
require_relative "methods"
require_relative 'sessions'
require_relative 'expenses'

class Expensable

  attr_accessor :expenses, :income 
  include Methods
  def start
    # Ya tengo mi start ahora debo hacer el loop del login 
    puts welcome
    action = ""
    until action == "exit"
      puts print_menu(:menu_login)
      action = get_inputs(print_menu(:menu_login))
      case action
      when "login"
        login
      when "create_user"
        puts "create here"
      when "exit"
        puts bye
      end
    end
  end

  def login
    login_data = login_form
    @user = Sessions.login(login_data)
    expenses_page
  end

  def expenses_page 
    @categories = Expenses.index(@user[:token])

    @expenses = @categories.select do |item|
      item[:transaction_type] == "expense"
    end

    @income = @categories.select do |item|
      item[:transaction_type] == "income"
    end

    puts notes_table(@expenses) # PODEMOS IMPRIMIR EXPENSES O INCOME POR EL PARAMETRO
    puts print_menu(:menu_categories)

  end

  def notes_table(table_data)
    table = Terminal::Table.new
    table.title = "Expenses\nDecember 2021"
    table.headings = ['ID', 'Category', 'Total']
    table.rows = table_data.map do |category|
      suma = 0
      category[:transactions].each { |item| suma += item[:amount]}
      [category[:id], category[:name], suma]
    end
    table
  end
end











def login_form # ESTO SE PEUDE ACORTAR CON LOS METODOS DE ENMANUEL 
  # print "Email: "
  # email = gets.chomp
  # print "Password: "
  # password = gets.chomp 
  # {email: email, password:password}
  {email: "test3@mail.com", password: "123456"}
end

app = Expensable.new
app.start