input_file_name = ARGV[0]
raw_data = File.read(input_file_name)
lines = raw_data.split("\n")
sum = 0

lines.each do |line|
  digits = line.scan(/\d/)
  first_digit = digits.first
  last_digit = digits.last
  line_val = "#{first_digit}#{last_digit}".to_i
  sum += line_val
end

puts sum
