require_relative 'human_player'
require_relative 'computer_player'

class Hangman
  MAX_ATTEMPTS = 6

  def initialize(guesser, checker, max_attempts = MAX_ATTEMPTS)
    @guesser = guesser
    @checker = checker
    @max_attempts = max_attempts
  end

  def self.human_vs_cpu
    Hangman.new(HumanPlayer.new, ComputerPlayer.new)
  end

  def self.cpu_vs_cpu
    Hangman.new(ComputerPlayer.new, ComputerPlayer.new)
  end

  def self.human_vs_human
    Hangman.new(HumanPlayer.new, HumanPlayer.new)
  end

  def self.test_cpu_performance(pool_size = 100)
    wins = 0

    pool_size.times do
      wins += 1 if Hangman.cpu_vs_cpu.play
    end

    win_pct = wins / (pool_size * 1.0) * 100

    puts "#{ wins } / #{ pool_size } win rate (#{ win_pct }%)"
  end

  def play
    secret_word_length = @checker.pick_secret_word
    @guesser.receive_secret_word(secret_word_length)
    @secret_word = Array.new(secret_word_length)
    
    @attempts = 0

    until game_over?
      puts "Secret word: #{secret_word}"

      guess = @guesser.guess
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

    puts "Guesser #{ won? ? 'wins' : 'loses' }!"
    puts "'#{ @checker.reveal_secret_word.join }' was the secret word."

    won?
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
end

if __FILE__ == $PROGRAM_NAME
  Hangman.human_vs_cpu.play
end
