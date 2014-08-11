class Hangman
	MAX_ATTEMPTS = 10

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

			@attempts += 1 if positions.empty?
		end
	end

	def game_over?
		@attempts >= @max_attempts
	end

	def secret_word
		@secret_word.map { |char| char.nil? ? "_" : char }.join(" ")
	end

	def self.valid_guess?(guess)
		guess.strip.length > 0 &&
		guess.downcase.strip.each_char.all? { |char| char.between?('a', 'z') }
	end
end

class ComputerPlayer
	DICTIONARY_FILE = "dictionary.txt"

	def initialize(file_name = DICTIONARY_FILE)
		@dictionary = File.readlines(file_name).map(&:chomp)
	end

	def pick_secret_word
		@secret_word = @dictionary.sample.split('')
		@secret_word.length
	end

	def receive_secret_word(length)
		@secret_word = Array.new(length)
	end

	def guess
		('a'..'z').to_a.sample
	end

	def check_guess(guess)
		[]
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

	def guess
		gets.chomp
	end

	def check_guess(guess)
		[]
	end
end

if __FILE__ == $PROGRAM_NAME
	guesser = HumanPlayer.new
	checker = ComputerPlayer.new
	game = Hangman.new(guesser, checker)
	game.play
end
