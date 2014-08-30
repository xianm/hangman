class HumanPlayer
  def pick_secret_word
    print "Think of a word. How long is it? "

    begin
      Integer(gets.chomp)
    rescue ArgumentError
      print "Invalid length, try again: "
      retry
    end
  end

  def receive_secret_word(length)
    puts "The word you have to guess is #{length} characters long."
  end

  def reveal_secret_word
    # TODO: should it prompt for the secret word and add it to the dictionary
    # if it's not in it?
    []
  end

  def guess
    while true
      print "> "
      guess = gets.chomp.downcase
      return guess if valid_guess?(guess)
    end
  end

  def valid_guess?(guess)
    /^[a-z]$/.match(guess)
  end

  def check_guess(guess)
    begin
      print "Where do any '#{guess}'s occur, if any (comma seperated): "
      positions = gets.chomp.split(",").map { |i| Integer(i) - 1 }
    rescue ArgumentError
      puts "Please use comma seperated values to indicate any occurances. Try again."
      retry
    end
  end

  def handle_guess_response(guess, positions)
  end
end
