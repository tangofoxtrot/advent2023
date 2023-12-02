input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

class Criteria
  attr_reader :color, :count
  def initialize(color:, count:)
    @color = color
    @count = count
  end

end

class CubePull
  COUNT_AND_COLOR_REGEX = /(?<count>\d+) (?<color>[a-z]+)/
  attr_reader :color, :count
  def initialize(color:, count:)
    @color = color
    @count = count
  end

  def meets_criteria?(criteria)
    if criteria.color != color
      return true
    else
      count <= criteria.count
    end
  end

  def to_critiera
    Criteria.new(color: color, count: count)
  end

  def to_s
    "#{count} #{color}"
  end

  def self.parse_line(line)
    line.split(",").map do |pull_data|
      match_data = pull_data.match(COUNT_AND_COLOR_REGEX)
      cube_count = match_data[:count].to_i
      cube_color = match_data[:color]
      new(color: cube_color, count: cube_count)
    end
  end
end

class Round
  attr_accessor :pulls
  def self.parse_line(round_line)
    round_line.split(";").map do |round_data|
      round = new
      round.pulls = CubePull.parse_line(round_data)
      round
    end
  end

  def initialize
    @pulls = []
  end

  def meets_criteria?(criteria)
    pulls.all? {|pull| pull.meets_criteria?(criteria) }
  end

  def to_s
    pulls.map(&:to_s).join(", ")
  end

  def to_criteria
    pulls.map(&:to_critiera)
  end
end

class Game
  NUMBER_AND_ROUNDS_REGEX = /^Game (?<number>\d+): (?<rounds>.*)$/
  attr_accessor :number, :rounds
  def initialize(number:)
    @number = number
    @rounds = []
  end

  def self.parse_line(line)
    match_data = line.match(NUMBER_AND_ROUNDS_REGEX)
    number = match_data[:number].to_i
    rounds_data = match_data[:rounds]
    game = new(number: number)
    game.rounds = Round.parse_line(rounds_data)
    game
  end

  def meets_criteria?(criteria)
    rounds.all? {|round| round.meets_criteria?(criteria) }
  end

  def minimum_criteria
    min = []
    rounds.map(&:to_criteria).flatten.group_by(&:color).each do |color, criteria|
      min << Criteria.new(color: color, count: criteria.map(&:count).max)
    end
    min
  end

  def power
    minimum_criteria.map(&:count).inject(:*)
  end

  def to_s
    "Game #{number}: #{rounds.map(&:to_s).join("; ")}"
  end
end

games = []
lines.each do |line|
  games << Game.parse_line(line)
end

criterias = [
  Criteria.new(color: 'red', count: 12),
  Criteria.new(color: 'green', count: 13),
  Criteria.new(color: 'blue', count: 14)
]

matching_games = games.select {|game| criterias.all? {|criteria| game.meets_criteria?(criteria) } }
puts "Puzzle 1 #{matching_games.map(&:number).sum}"

games.each do |game|
  puts "Game #{game.number}: power: #{game.power}"
end
puts "Total power: #{games.map(&:power).sum}"
