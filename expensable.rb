# Start here. Happy coding!
require "terminal-table"
require "httparty"
require "json"
require "date"
require_relative "methods"
require_relative "sessions"
require_relative "expenses"

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
      when "show"
        id.nil? ? (puts "Id required") : show(id.to_i)
      when "update"
        id.nil? ? (puts "Id required") : update_category(id.to_i)
      when "delete"
        id.nil? ? (puts "Id required") : delete_category(id.to_i)
      when "add-to" 
        id.nil? ? (puts "Id required") : add_to(id.to_i)
      when "toggle" then toggle
      when "next" then next_month
      when "prev" then prev_month
      when "logout" then Sessions.logout(user[:token])
      else puts "Invalid options!"
      end
    end
  end

  def add_to(id_tran)
    data = form_transaction
    new_data = Expenses.add_transaction(id_tran, user[:token], data)
    data = @actual_table.select { |values| values[:id] == id_tran }
    index = @actual_table.index(data[0])
    data[0][:transactions].push(new_data)
    @actual_table.reject! { |value| value[:id] == id_tran }
    @actual_table.insert(index, data[0])
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
    table.headings = ["ID", "Category", "Total"]
    table.rows = table_data.map do |category|
      suma = 0
      # sumamos :amount solo si coincide con la fecha
      category[:transactions].each do |item|
        suma += item[:amount] if Date.parse(item[:date]).strftime("%B %Y") == date
      end
      [category[:id], category[:name], "S/. #{suma}"]
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

  def show(id_tran)
    @transactions = @actual_table.find do |item|
      item[:id] == id_tran
    end
    name_transaction = @transactions[:name]
    @transactions = @transactions[:transactions]
    action, id = ""
    until action == "back"
      puts table_show_id(@transactions, name_transaction)
      puts print_menu(:menu_transaction)
      print "> "
      action, id = gets.chomp.split
      case action
      when "add" then add(id_tran.to_i)
      when "update"
        id.nil? ? (puts "Id required") : update(id_tran.to_i, id.to_i) # pasar el id
      when "delete"
        id.nil? ? (puts "Id required") : delete(id_tran.to_i, id.to_i)
      when "next" then next_month
      when "prev" then prev_month
      when "back" then ""
      else puts "Invalid options!"
      end
    end
  end

  def add(id_tran)
    data = form_transaction
    new_data = Expenses.add_transaction(id_tran, user[:token], data)
    @transactions.push(new_data)
  end

  def update(id_tran, id)
    data = form_transaction
    new_data = Expenses.update_transaction(id_tran, id, user[:token], data)
    @transactions.reject! { |transactions| transactions[:id] == id }
    @transactions.push(new_data)
  end

  def delete(id_tran, id)
    Expenses.delete_transaction(id_tran, user[:token], id)
    @transactions.reject! { |transactions| transactions[:id] == id }
  end

  def table_show_id(table_data, title)
    table = Terminal::Table.new
    table.title = "#{title}\n#{date}"
    table.headings = ["ID", "Date", "Amount", "Notes"]
    table_data = table_data.select do |value|
      Date.parse(value[:date]).strftime("%B %Y") == date # unless item[:transactions].empty?
    end
    table.rows = table_data.map do |note|
      dates = Date.parse(note[:date]).strftime("%a, %b %d")
      [note[:id], dates, "S/. #{note[:amount]}", note[:notes]]
    end
    table
  end

  def delete_category(id)
    Expenses.destroy(user[:token], id) # ELIMINA EN EL API
    # DEBEMOS ELIMINAR EN LOCAL Y MOSTRAR LA TABLA
    @actual_table.reject! { |data| data[:id] == id }
  end

  def create_category
    data = form_category
    # ENVIAMOS EL KEY Y LA DATA
    new_data = Expenses.create_expense(user[:token], data)
    @actual_table.push(new_data)
  end

  def update_category(id)
    data = form_category
    new_data = Expenses.update_category(@user[:token], id, data)
    @actual_table.reject! { |table| table[:id] == id }
    @actual_table.push(new_data)
  end
end

app = Expensable.new
app.start
