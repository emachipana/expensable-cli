module Methods
  def welcome
    [
      "####################################",
      "#       Welcome to Expensable      #",
      "####################################"
    ]
  end
    
  def print_menu(name_menu)
    options = {
      menu_login: "login | create_user | exit",
      menu_categories: "create | show ID | update ID | delete ID\nadd-to ID | toggle | next | prev | logout" 
    }
    options[name_menu]
  end

  def get_inputs(options)
    print "> "
    input = gets.chomp
    input = empty(input)
    until options.include?(input)
        puts "Invalid Options!"
        print "> "
        input = gets.chomp
    end
    input
  end

  def empty(input)
    while input.empty?
        puts "Cannot be blank"
        print "> "
        input = gets.chomp
    end
    input
  end
  
  def bye
    [
    "####################################",
    "#   Thanks for using Expensable    #",
    "####################################"
    ]
  end
end