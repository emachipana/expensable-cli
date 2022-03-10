# Start here. Happy coding!
require "terminal-table"
require_relative "methods"
class Expensable
  include Methods
  def start
    puts welcome
    action = ""
    until action == "exit"
      puts print_menu(:menu_login)
      action = get_inputs(print_menu(:menu_login))
      case action
      when "login"
        puts "login here"
      when "create_user"
        puts "create here"
      when "exit"
        puts bye
      end
    end
  end
    
end

app = Expensable.new
app.start