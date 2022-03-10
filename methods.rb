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

  def valid_email(email)
    until email.match?(/[a-z]*@[a-z]*\.[a-z]{2,3}/)
      puts "Invalid format"
      print "Email: "
      email = gets.chomp
    end
    email
  end

  def valid_password(password)
    until password.length >= 6
      puts "Minimum 6 characters"
      print "Password: "
      password = gets.chomp
    end
    password
  end

  def login_form
    print "Email: "
    email = gets.chomp
    # email = empty(email)
    email = valid_email(email)
    print "Password: "
    password = gets.chomp
    # password = empty(password)
    password = valid_password(password)
    {email: email, password: password}
  end
  
  def bye
    [
    "####################################",
    "#   Thanks for using Expensable    #",
    "####################################"
    ]
  end
end

