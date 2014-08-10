class Hangman
	def initialize(guesser, checker)
		@guesser = guesser
		@checker = checker
	end

	def play
		@secret_word = @checker.pick_word

		while true # todo: game over check goes here
			puts "Secret word: #{@secret_word}"
			print "> "
			char = gets.chomp
		end
	end
end

class ComputerPlayer
	def initialize(file_name)
		@dictionary = File.readlines(file_name).map(&:chomp)
	end

	def pick_word
		@dictionary.sample
	end
end
