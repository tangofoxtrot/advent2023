input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

class Card
  def self.parse(line)
    parts = line.split("|")
    number = parts.first[/Card(?:\s)+(\d+)/,1]
    actual_values = parts.first.split(":").last.scan(/(\d+)/).flatten.map(&:to_i)
    winning_values = parts.last.scan(/(\d+)/).flatten.map(&:to_i)
    new(number: number.to_i, winning: winning_values, actual: actual_values)
  end

  attr_reader :winning, :actual, :number

  def initialize(number:, winning:, actual:)
    @winning = winning
    @actual = actual
    @number = number
  end

  def value
    if winning_count == 1
      1
    else
      (2**(winning_count - 1)).to_i
    end
  end

  def copy
    self.class.new(number: number, winning: winning, actual: actual)
  end

  def winning_count
    (winning & actual).length
  end

  def prize_cards
    (number + 1).upto(number + winning_count).to_a
  end
end

cards = []
lines.each do |line|
  cards << card = Card.parse(line)
end


puts "Puzzle1: #{cards.map(&:value).sum}"

cards.each do |card|
  card.prize_cards.each do |prize_card_number|
    prize_card = cards.detect {|x| x.number == prize_card_number }
    cards << prize_card.copy
  end
end

puts "Puzzle2: #{cards.length}"
