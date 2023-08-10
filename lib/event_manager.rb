require 'csv'
puts 'Event Manager Initialized!'

# Use the CSV Library
contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

contents.each do |row|
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])

    puts "#{name} #{zipcode}"
end

# Read the file 
# lines = File.readlines('event_attendees.csv')
# lines.each_with_index do |line, index|
#     next if index == 0 # skips the first row
#     columns = line.split(",")
#     name = columns[2]
#     puts name
# end