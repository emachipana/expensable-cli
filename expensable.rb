# Start here. Happy coding!
require "terminal-table"
require "httparty"
require "json"
require "date"
require_relative "methods"
require_relative 'sessions'
require_relative 'expenses'

class Expensable
  attr_accessor :expenses, :income, :user, :categories, :date
  
  include Methods
  def start
    @date = Date.today.strftime("%B %Y")
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
    
    action, id = ""
    puts print_menu(:menu_categories)

    until action == "logout"
      action, id = gets.chomp.split
      case action 
      when "create" then create_category
      when "show" then p "show"
      when "update" then update_category(id.to_i)
      when "delete" then delete_category(id.to_i)
      when "add-to" then p "add-to"
      when "toggle" then p "toggle"
      when "next" then p "next"
      when "prev" then p "prev"
      when "logout" then p "logout"
      else p "Escribe una opcion correcta"
      end
    end
  end

  def notes_table(table_data, title)
    table = Terminal::Table.new
    table.title = "#{title}\n#{date}"
    table.headings = ['ID', 'Category', 'Total']
    # SOLAMENTE VAMOS A SUMAR SI HACE MATCH CON LA FECHA 
    table.rows = table_data.map do |category|
      suma = 0
      category[:transactions].each { |item| suma += item[:amount]}
      [category[:id], category[:name], suma]
    end
    table
  end

  def delete_category(id)
    Expenses.destroy(user[:token], id) # ELIMINA EN EL API
    # DEBEMOS ELIMINAR EN LOCAL Y MOSTRAR LA TABLA
    @expenses.reject! { |expense| expense[:id] == id}
    puts notes_table(expenses, "Expenses")
  end

  def create_category
    data = { name: "New Expense3", transaction_type: "expense" }
    # ENVIAMOS EL KEY Y LA DATA
    new_data = Expenses.create_expense(user[:token], data)
    @expenses.push(new_data) 
    puts notes_table(expenses, "Expenses")
  end

  def update_category(id)
    data = { name: "New Expense", transaction_type: "expense" }
    Expenses.update(user[:token], id, data)
  end

  def next_month
    @date = date.next_month.strftime("%B %Y")
  end

  def prev_month
    @date = date.prev_month.strftime("%B %Y")
  end

end

app = Expensable.new
app.start