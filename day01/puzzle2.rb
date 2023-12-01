input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")
NUMBER_WORD_MAP = Hash.new { |hsh, k| k.to_i }
NUMBER_WORD_MAP.merge!({
  "one" => 1,
  "two" => 2,
  "three" => 3,
  "four" => 4,
  "five" => 5,
  "six" => 6,
  "seven" => 7,
  "eight" => 8,
  "nine" => 9,
})

REGEX = /(?=(#{(NUMBER_WORD_MAP.keys + ["\\d"]).join("|")}))/
sum = 0

lines.each do |line|
  digits = line.scan(REGEX).flatten
  first_digit = NUMBER_WORD_MAP[digits.first]
  last_digit = NUMBER_WORD_MAP[digits.last]
  line_val = "#{first_digit}#{last_digit}".to_i
  sum += line_val
end

puts sum
