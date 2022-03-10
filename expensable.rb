# Start here. Happy coding!
require "terminal-table"
require "httparty"
require "json"
require "date"
require_relative "methods"
require_relative 'sessions'
require_relative 'expenses'

class Expensable
  attr_accessor :expenses, :income, :user, :categories, :date, :transaction_type
  
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
    
    action, id = ""
    # datos de la tabla por default
    @actual_table_name = "Expenses"
    @actual_table = expenses
    until action == "logout"
      puts notes_table(@actual_table, @actual_table_name) # PODEMOS IMPRIMIR EXPENSES O INCOME POR EL PARAMETRO
      puts print_menu(:menu_categories)
      print "> "  
      action, id = gets.chomp.split
      case action 
      when "create" then create_category
      when "show" then p "show"
      when "update" then update_category(id.to_i)
      when "delete" then delete_category(id.to_i)
      when "add-to" then p "add-to"
      when "toggle" then toggle 
      when "next" then next_month
      when "prev" then prev_month
      when "logout" then Sessions.logout(user[:token])
      else p "Escribe una opcion correcta"
      end
    end
  end

  def toggle
    # cambiamos de tabla
    if @actual_table_name == "Expenses"
      @actual_table_name = "Income"
      @actual_table = income 
    else
      @actual_table_name = "Expenses"
      @actual_table = expenses
    end
  end

  def notes_table(table_data, title)
    table = Terminal::Table.new
    table.title = "#{title}\n#{date}"
    table.headings = ['ID', 'Category', 'Total']
    # #table_data = table_data.select do |item|
    #   item[:transactions].find do |value|
    #     Date.parse(value[:date]).strftime("%B %Y") == date #unless item[:transactions].empty?
    #   end
    # #end
    # imprimimos la tabla validada con la fecha
    table.rows = table_data.map do |category|
      suma = 0
      #sumamos :amount solo si coincide con la fecha
      category[:transactions].each do |item|
       suma += item[:amount] if Date.parse(item[:date]).strftime("%B %Y") == date #unless category[:transactions].empty?
      end
      [category[:id], category[:name], suma]
    end
    table
  end

  def next_month
    date_t = Date.parse(date)
    @date = date_t.next_month.strftime("%B %Y")
  end

  def prev_month
    date_t = Date.parse(date)
    @date = date_t.prev_month.strftime("%B %Y")
  end

  def delete_category(id)
    Expenses.destroy(@user[:token], id) # ELIMINA EN EL API
    # DEBEMOS ELIMINAR EN LOCAL Y MOSTRAR LA TABLA
    @expenses.reject! { |expense| expense[:id] == id}
    # puts notes_table(expenses, "Expenses")

    variable = @categories.find do |category|
      category[:id] == id
    end

    case variable[:transaction_type]
    when "expense"
      @expenses.reject! { |expense| expense[:id] == id}
      @actual_table_name = "Expenses"
      @actual_table = expenses
      #puts notes_table(expenses, "Expenses")
    when "income"
      @income.reject! { |income| income[:id] == id}
      @actual_table_name = "Income"
      @actual_table = income
      #puts notes_table(income, "Income")
    end
  end

  def create_category
    data = { name: "New Expense3", transaction_type: "expense" }
    print "Name: "
    name = gets.chomp
    print "Transaction Type: "
    transaction_type = gets.chomp
    data = { name: name, transaction_type: transaction_type }
    # ENVIAMOS EL KEY Y LA DATA
    new_data = Expenses.create_expense(@user[:token], data)
    if transaction_type == "income"
      @income.push(new_data) 
      #puts notes_table(income, "Income")
      @actual_table_name = "Income"
      @actual_table = income
    elsif transaction_type == "expense" 
      @expenses.push(new_data)
      #puts notes_table(expenses, "Expenses")
      @actual_table_name = "Expenses"
      @actual_table = expenses
    end
  end

  def update_category(id)
    data = { name: "New Expense", transaction_type: "expense" }
    Expenses.update_category(@user[:token], id, data)
    print "Name: "
    name = gets.chomp
    print "Transaction Type: "
    transaction_type = gets.chomp
    data = { name: name, transaction_type: transaction_type }
    new_data = Expenses.update_category(@user[:token], id, data)
    if transaction_type == "income"
      @income.reject! { |income| income[:id] == id}
      @income.push(new_data) 
      @actual_table_name = "Income"
      @actual_table = income
    elsif transaction_type == "expense"
      @expenses.reject! { |expense| expense[:id] == id} 
      @expenses.push(new_data)
      @actual_table_name = "Expenses"
      @actual_table = expenses
    end
    # system("clear")
  end

end

app = Expensable.new
app.start

