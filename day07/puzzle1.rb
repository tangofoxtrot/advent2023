input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

HIGH_CARD_VALUES = %w{A K Q J T 9 8 7 6 5 4 3 2}.reverse.each_with_index.inject({}) {|hsh, (c, index)| hsh[c] = index; hsh }
JOKER_HIGH_CARD_VALUES = %w{A K Q T 9 8 7 6 5 4 3 2 J}.reverse.each_with_index.inject({}) {|hsh, (c, index)| hsh[c] = index; hsh }

class HandType
  FIVE_KIND = 6
  FOUR_KIND = 5
  FULL_KIND = 4
  THREE_KIND = 3
  TWO_PAIR_KIND = 2
  ONE_PAIR_KIND = 1
  HIGH_CARD_KIND = 0

  def self.for(cards, jokers: false)
    if jokers
      return for_with_joker(cards)
    end

    grouped_cards = cards.chars.tally
    if grouped_cards.values.first == 5
      FIVE_KIND
    elsif grouped_cards.values.sort == [1,4]
      FOUR_KIND
    elsif grouped_cards.values.sort == [2,3]
      FULL_KIND
    elsif grouped_cards.values.include?(3)
      THREE_KIND
    elsif grouped_cards.values.sort == [1,2,2]
      TWO_PAIR_KIND
    elsif grouped_cards.values.sort == [1,1,1,2]
      ONE_PAIR_KIND
    else
      HIGH_CARD_KIND
    end
  end

  def self.for_with_joker(cards)
    grouped_cards = cards.chars.tally
    joker_count = grouped_cards["J"] || 0
    if grouped_cards.values.first == 5
      FIVE_KIND
    elsif grouped_cards.values.sort == [1,4]
      case joker_count
      when 1,4
        FIVE_KIND
      else
        FOUR_KIND
      end
    elsif grouped_cards.values.sort == [2,3]
      case joker_count
      when 2,3
        FIVE_KIND
      else
        FULL_KIND
      end
    elsif grouped_cards.values.include?(3)
      case joker_count
      when 3,1
        FOUR_KIND
      when 2
        FULL_KIND
      else
        THREE_KIND
      end
    elsif grouped_cards.values.sort == [1,2,2]
      case joker_count
      when 2
        FOUR_KIND
      when 1
        FULL_KIND
      else
        TWO_PAIR_KIND
      end
    elsif grouped_cards.values.sort == [1,1,1,2]
      case joker_count
      when 2,1
        THREE_KIND
      else
        ONE_PAIR_KIND
      end
    else
      case joker_count
      when 1
        ONE_PAIR_KIND
      else
        HIGH_CARD_KIND
      end
    end
  end

end


class Hand

  attr_reader :cards, :bid, :hand_type

  def initialize(cards:, bid:, card_values:, hand_type: )
    @cards = cards
    @bid = bid.to_i
    @hand_type = hand_type
    @card_values = card_values
  end

  def <=>(other)
    if hand_type > other.hand_type
      return 1
    elsif hand_type == other.hand_type
      return high_card_sort(other)
    else
      return -1
    end
  end

  def high_card_sort(other)
    cards.chars.each_with_index do  |card, index|
      card_val = @card_values[card]
      other_card = other.cards[index]
      other_card_val = @card_values[other_card]
      if card_val > other_card_val
        return 1
      elsif card_val < other_card_val
        return -1
      end
    end

  end

end

cards = lines.map do |line|
  cards, bid = line.split(" ")
  hand_type = HandType.for(cards)
  Hand.new(cards: cards, bid: bid, hand_type: hand_type, card_values: HIGH_CARD_VALUES)
end
puzzle1 = cards.sort.each_with_index.map do |c, index|
  c.bid * (index + 1)
end.sum

puts "Puzzle 1: #{puzzle1}"

cards = lines.map do |line|
  cards, bid = line.split(" ")
  hand_type = HandType.for(cards, jokers: true)
  Hand.new(cards: cards, bid: bid, hand_type: hand_type, card_values: JOKER_HIGH_CARD_VALUES)
end

puzzle2 = cards.sort.each_with_index.map do |c, index|
  c.bid * (index + 1)
end.sum

puts "Puzzle 2: #{puzzle2}"
