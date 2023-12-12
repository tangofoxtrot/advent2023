input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")

SEEDS_REGEX = /^seeds:/
NEW_MAP_REGEX = /^([a-z-]+) map:/
MAP_ENTRY_REGEX = /(?<destination>\d+) (?<source>\d+) (?<length>\d+)/

class GameScenario
  attr_reader :hold_time, :max_time, :speed

  def initialize(hold_time:, max_time:)
    @hold_time = hold_time
    @max_time = max_time
    @speed = hold_time
  end

  def distance
    run_time = max_time - hold_time
    run_time * speed
  end

end

class Game
  attr_reader :number, :time, :distance

  def initialize(number:, time:, distance:)
    @number = number
    @time = time
    @distance = distance
  end

  def winning_runs
    winners = []
    (1...time).each do |n|
      s = GameScenario.new(hold_time: n, max_time: time)
      if s.distance > distance
        winners << s
      end
    end
    winners
  end
end

games = []
times = lines.first.scan(/\d+/).map(&:to_i)
distances = lines.last.scan(/\d+/).map(&:to_i)

times.zip(distances).each_with_index do |(time, distance), index|
  games << Game.new(number: index + 1, time: time, distance: distance)
end

puts "Puzzle1 #{games.map {|x| x.winning_runs.count }.reduce(:*)}"

time = lines.first.scan(/\d+/).join.to_i
distance = lines.last.scan(/\d+/).join.to_i

game = Game.new(number: 1, time: time, distance: distance)

puts "Puzzle2 #{game.winning_runs.count}"
