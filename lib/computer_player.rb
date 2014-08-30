require_relative 'dictionary'

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
    puts "> #{ letter }" # simulate input in the console
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
