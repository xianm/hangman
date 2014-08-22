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
    @words.reject! { |el| el.include?(letter) }
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
