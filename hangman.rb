class Hangman
  MAX_ATTEMPTS = 6

  def initialize(guesser, checker, max_attempts = MAX_ATTEMPTS)
    @guesser = guesser
    @checker = checker
    @max_attempts = max_attempts
  end

  def play
    secret_word_length = @checker.pick_secret_word
    @guesser.receive_secret_word(secret_word_length)
    @secret_word = Array.new(secret_word_length)
    
    @attempts = 0

    until game_over?
      puts "Secret word: #{secret_word}"

      begin
        print "> "
        guess = @guesser.guess
      end until self.class.valid_guess?(guess)

      positions = @checker.check_guess(guess)

      @guesser.handle_guess_response(guess, positions)

      unless positions.empty?
        positions.each do |i|
          @secret_word[i] = guess
        end
      else
        @attempts += 1
        puts "Incorrect, #{@max_attempts - @attempts} attempts left!"
      end
    end

    if won?
      puts "Guesser wins!"
    else
      puts "Guesser loses! "
      @secret_word = @checker.reveal_secret_word
    end

    puts "'#{secret_word}' was the secret word."
  end

  def game_over?
    won? || lost?
  end

  def won?
    @secret_word.none? { |el| el.nil? }
  end

  def lost?
    @attempts >= @max_attempts
  end

  def secret_word
    @secret_word.map { |char| char.nil? ? "_" : char }.join
  end

  def self.valid_guess?(guess)
    guess.strip.length > 0 &&
    guess.downcase.strip.each_char.all? { |char| char.between?('a', 'z') }
  end
end

class ComputerPlayer
  def initialize(dictionary = Dictionary.new)
    @dictionary = dictionary
    @already_guessed = []
  end

  def pick_secret_word
    @secret_word = @dictionary.sample.split('')
    @secret_word.length
  end

  def receive_secret_word(length)
    @secret_word = Array.new(length, '.')
    @dictionary.filter_by_length(length)
  end

  def reveal_secret_word
    @secret_word
  end

  def guess
    possible_letters = @dictionary.letters_by_frequency(@already_guessed)
    letter = possible_letters.first
    @already_guessed << letter
    puts letter # simulate input in the console
    letter
  end

  def check_guess(guess)
    [].tap do |positions|
      @secret_word.each_with_index { |c, i| positions << i if c == guess }
    end
  end

  def handle_guess_response(guess, positions)
    if positions.empty?
      @dictionary.filter_words_containing(guess)
    else
      positions.each do |i|
        @secret_word[i] = guess
      end

      exp = @secret_word.join('')
      @dictionary.filter_by_regexp(exp)
    end
  end
end

class HumanPlayer
  def initialize
  end

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
    # todo: should it prompt for the secret word and add it to the dictionary
    # if it's not in it?
    []
  end

  def guess
    gets.chomp
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
end

class Dictionary
  DICTIONARY_FILE = "dictionary.txt"

  attr_reader :words

  def initialize(file = DICTIONARY_FILE)
    @words = File.readlines(file).map(&:chomp)
  end

  def sample
    @words.sample
  end

  def filter_by_length(length)
    @words.select! { |el| el.length == length }
  end

  def filter_by_regexp(exp_str)
    exp = Regexp.new(exp_str)
    @words.select! { |el| el.match(exp) }
  end

  def filter_words_containing(letter)
    @words.select! { |el| !el.include?(letter) }
  end

  def letters_by_frequency(ignore_letters = [])
    generate_histogram(ignore_letters).sort_by { |k, v| v }.transpose.first.reverse
  end

  def generate_histogram(ignore_letters = [])
    histogram = Hash.new { 0 }

    @words.each do |word|
      word.each_char do |char|
        histogram[char] += 1 unless ignore_letters.include?(char)
      end
    end

    histogram
  end
end

if __FILE__ == $PROGRAM_NAME
  guesser = ComputerPlayer.new
  checker = HumanPlayer.new
  game = Hangman.new(guesser, checker)
  game.play
end
